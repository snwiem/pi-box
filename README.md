# pi-box

An optinionated container for agent harness.

## Motivation

[pi coding agent](http://pi.dev) is great. pi coding agent is powerfull. pi coding agent is unleashed.

That's exactly why in certain use-cases it makes sense to ban pi into a controlled environment, giving pi only access to directories it only needs for it's job.
pi is also very customizable, but initially also very lean. Customizing pi globally with extensions, skill, prompts and such make pi itself much less lean. It would be great
to be able to customize a pi instance exactly to the job it's about to be doing.

## Ideas

- pi should be easily started using a container
- the pi container only includes the basic requirements to run pi (node, npm and such)
- pi container is started for a specific 'profile'. the profile concept is explained below
- during container start it's possible to mount volumnes (directories) into pi
- container start should be wrapped into a tool (shell, script, etc)

## Profiles

The profile concept should provide individual setups of a pi instance.

### Context

One core concept of pi are [context files](https://pi.dev/docs/latest/usage#context-files). There are AGENTS.md files which describe the general agents behaviour and defines the agents overal context. there is also SYSTEM.md and APPEND_SYSTEM.md files which allow to modify the core system context. It's best practice not
to change SYSTEM.md bit it's common practice to add an APPEND_SYSTEM.md to modify the core system context.

pi allows this files to be stored in the users pi global directory (`~/.pi/agent/) and to overlay them with project local versions of AGENTS.md and APPEND_SYSTEM.md on a per project directory basis. AGENTS.md is also search upwards in the directory tree.

### Sessions

Sessions are the 'brain' of pi for a single instance. it's a core and very powerfull concept of pi to persist session states across pi instances.

According to [pi session docs](https://pi.dev/docs/latest/sessions) sessions are stored in the user home directory of the user running the pi instance.
That does not match the idea of pi-box. pi-box should be able to persist session data accross container restarts, but should not necessarily require to store the session data int the default session location. It's possible to configure the session storage directory for the pi instance indivudually using the pi settings.json configuration (see [session settings](https://pi.dev/docs/latest/settings#sessions))

### Extensions

pi allows to be extended by code which enable pi to use additional tools. extensions are usually typescript programs int `~/.pi/agent/extensions` or `.pi/extensions` (see [pi extensions](https://pi.dev/docs/latest/extensions)). extensions are a critical part of pi as they provide runtime code. the pi user must trust this extensions and secure them. so using a specific profile limits those extensions to only those provided by the current selected profile, reducing the risk to load extension which might harm the system without actually requiring it for the current pi instance.

### Skills

[Skills](https://pi.dev/docs/latest/skills) are the most important part of pi configuration. They clearly define skill the agent is allowed and should use to get it's job done the best way it can. Usually you define certain tooling in SKILL or behaviours which modifify and define the way the agent acts on certain tasks. They can either be defined globally in `~/.pi/agent/skills` or `~/.agents/skills` or locally at `.pi/agent/skills` and `.agents/skills`. skill can also be added at command line level when strting the pi agent.

### Templates

pi also provides the capability to use [prompt templates](https://pi.dev/docs/latest/prompt-templates). prompt templates contains specific prompts which are used very regularily. They can be placed, like skills, globally in `~/.pi/agent/prompts` or locally at `.pi/prompts/`. 

### Themes

Finally pi adds themes. Themes allow to change to look of the pi instance tui (terminal ui). For profiles this can help to distinguish between different profiles (eg by color) or the completely redesign the tui for the specific profile needs (eg subagents windows). Themes can be provided globally at `~/.pi/agent/themes`, locally at `.pi/themes` or by command line. Additionally the theme location can be configured using the `settings.json`.

## Containers

pi-box is based on the core concept of containers. pi-box provided a ready made _base image_ which can be extended to add additional tooling like editors, development envronments and such. pi-box does not provide fully equipped containers containing everything everyone might require for their profiles. Each profile defines it's own image `container.json` which defines the final container based on the core pi-box base image.

Building (updating) the image should be automatically done when the profile is used. If the image is already locally available it should be not re-build, except the container.json definition has changed or the recreation is forced.

Container runtime should be OIC compatible. Preferred runtime is rootless podman. For now this is the hard requirement that podman is available on the host system.

Usually containers require access to container runtime also. this should not be using container-in-container, but should allow the pi-box container (or it's derivate) to use the host system container environment.

## Project management

pi-box contains of two individual repositories. the core pi-box repository which contains the pi-box container definition, all tools to create the container image and an entry point (script, program) to start a pi-box session with a certain profile. This is usually checked out from github by the user. the pi-box tools (container creation, running pi-box instance, etc) are either directory called from this directory or there is an installation phase which installs all required tools into the users home environment. this needs to be further refined when we get a better idea what pi-box privides.

the second repository is a pi-box profile repository. this usually contains all files defining different profile usable by pi-box. pi-box profiles should be able to be managed by a version control system (eg git). An idea would be to use a standard location in the users home directory like `~/.pi-box/<profile>`.

## Workflow

The usual workflow is as follows:

- User checks out pi-box repository from github and "installs" the required tools so that they are accessible from the users terminal. (this includes creating/updating) the pi-box base image. later it might be possible to use a pi-box base image from a global container registry.
- User provides `~/.pi-box/<profiles>`. profiles can contain container.yml files which define specific container images based on pi-box base image
- User starts a specific pi-box session using a specific <profile>. the start script creates the container image and configures the pi agent with <profile> specific files.
- User works with pi-box instance on specific drectories. directories are mounted into the container on startup. there might be read-only and read-write volume mounts
- User can stop working with pi-box instance and resume session at any time later on. this means pi session data must be persisted into a volume. (accessing session data is not allowed from the host system directly, so container volumes are a valid choice)

## Requirements

- podman (rootless) as container environment
- pi-box should only require basic tools which are usually available on any *nix based system (including Windows Git Bash, Cygwin and msys2)
- pi-box should be easily usable by everyone with basic terminal know how. help on how to use and execute pi-box tools is a must.
