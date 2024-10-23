# Robopages

Robopages are YAML based files for describing tools to large language models (LLMs). They simplify the process of defining and using external tools in LLM-powered applications. By leveraging the [robopages function calling server](https://github.com/dreadnode/robopages-cli), developers can avoid the tedious task of manually writing JSON declarations for each tool. This approach streamlines tool integration, improves maintainability, and allows for more dynamic and flexible interactions between LLMs and external utilities.

Like [man pages](https://en.wikipedia.org/wiki/Man_page) but for robots!

## Usage

Download this repository and copy it to your system `~/.robopages/` folder. Refer to https://github.com/dreadnode/robopages-cli for usage information.

## Syntax

A robopage is a YAML file describing one or more tools that can be used by an LLM as functions. In its simplest form, a robopage is a YAML file with a `description` and a `functions` section referencing a command line tool:

```yaml
description: You can use this for a description.

# declare one or more functions per page
functions:
  # the function name
  example_function_name:
    description: This is an example function describing a command line.
    # function parameters
    parameters:
      # the parameter name
      foo:
        # the parameter type
        type: string
        description: An example paramter named foo.
        # whether the parameter is required, default to true
        # required: false
        # optional examples of valid values
        examples:
        - bar
        - baz

    # the command line to execute
    cmdline:
    - echo
    # valid syntax for parameters interpolation:
    #   ${parameter_name}
    #   ${parameter_name or default_value}
    - ${foo}
```

It is possible to declare a container section, in which case the command line will be executed in the context of the container if the application doesn't exist in $PATH on the host system (note that in the following example the `force` option is set to true in order to ensure that the container image is used instead):

```yaml
description: An example using a docker image.

# declare one or more functions per page
functions:
  # the function name
  http_get:
    description: Fetch a page from the web.
    # function parameters
    parameters:
      # the parameter name
      url:
        # the parameter type
        type: string
        description: The URL of the page to fetch.
        examples:
        - https://example.com

    # the container to use
    container:
      # normally, if the binary specificed in cmdline is found in $PATH,
      # it will be used instead of the container binary
      # by setting force to true, the container image will be used instead
      force: true
      # the container image to use
      image: alpine/curl
      # optional volumes to mount
      # volumes:
      # - /var/run/docker.sock:/var/run/docker.sock
      # optional container arguments
      args:
        # share the same network as the host
        - --net=host

    # the command line to execute
    cmdline:
    - curl
    - -s
    - -L
    - ${url}
```

Local Dockerfiles can be used as well (use the `${cwd}` variable to refer to the directory of the robopage.yml file):

```yaml
description: An example using a docker container built locally.

# declare one or more functions per page
functions:
  # the function name
  nmap_tcp_ports_syn_scan:
    description: Scan one or more targets for the list of common TCP ports using a TCP SYN scan.
    # function parameters
    parameters:
      # the parameter name
      target:
        # the parameter type
        type: string
        description: The IP address, CIDR, range or hostname to scan.
        # optional examples of valid values
        examples:
          - 192.168.1.1
          - 192.168.1.0/24
          - scanme.nmap.org

    # the container to use
    container:
      # normally, if the binary specificed in cmdline is found in $PATH,
      # it will be used instead of the container binary
      # by setting force to true, the container image will be used instead
      force: true
      # specify how to build the container image
      build: 
        # path to the Dockerfile, ${cwd} is the directory of the robopage.yml file
        path: ${cwd}/nmap.Dockerfile
        # how to tag the image
        name: nmap_local

      # optional volumes to mount
      # volumes:
      # - /var/run/docker.sock:/var/run/docker.sock
      # optional container arguments
      args:
        # share the same network as the host
        - --net=host

    # the command line to execute
    cmdline:
      # sudo is automatically removed if running as container
      - sudo
      - nmap
      - -sS
      - -Pn
      - -A
      - ${target}
```