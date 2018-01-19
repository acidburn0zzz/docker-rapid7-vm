# InsightVM/Nexpose Console and Engine Docker Images

The Rapid7 InsightVM/Nexpose Console and Engine Docker Images.  These are functioning vulnerability management 
tools: https://www.rapid7.com/solutions/vulnerability-management/

__DISCLAIMER__: the resulting Docker images and the files found in this repository are meant for _Proof of Concept_ and 
_Testing_ purposes.  They are __NOT__ officially supported images and are not supported by Rapid7 Support.  Best effort 
is used to keep the images up to date and resolve reported issues/bugs.

### About
This implementation was designed to build and run docker containers for both the InsightVM/Nexpose Console and Engine.  
 It is a quick way to interact with the API, get acquainted with the tool, or any other purposes that may not require a 
 a generated license.  It is not recommended to use these images in a persistent state or for production purposes.

### Usage
Running the Rapid7 VM Console while exposing the UI/API port (3780) and Engine Listener port (40815) for E -> C pairing:
```
docker run --init -p 3780:3780 -p 40815:40815 rapid7/rapid7-vm-console
```

Once the Console has been started and the login page is accessible at `https://localhost:3780` (from host system), the 
default username is `nxadmin` and default password is `nxpassword`.

Running the Rapid7 VM Engine while exposing the Console Listener port (40814) for C -> E pairing:
```
docker run --init -p 40814:40814 rapid7/rapid7-vm-engine
```

### Pairing Engine -> Console using shared secret
Depending on the environment and workflow, it can be easier to automatically pair the scan engine with the console using a shared secret.
This method will automatically create the engine in the Nexpose/InsightVM console to be ready to use for scanning activity.
Going to Administration -> Engines -> Manage, then scrolling to the bottom of the page, you can generate a shared secret.

Environment variables to be used in the `docker run` command:

* SECRET: The shared secret generated on the console manually or via an API call
* CONSOLE: The Nexpose/InsightVM console host or ip address.  The scan engine requires this to know what console to pair with

Using the shared secret generated on the console either using the API or manually:
```
docker run --init -d --name "vm-engine" -e SECRET='XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX' -e CONSOLE='127.0.0.1' rapid7/rapid7-vm-engine
```

### Activating Console at Startup
It is possible to pass an Activation Key or Activation License File with the use of environment variables.  By setting
one of these variables, at startup the Console API will be used to activate your console image.  NOTE: The console will 
only be activated if the current license status is "Unlicensed".

Activate by Key with ACTIVATION_KEY environment variable:
```
docker run --init -d --name "vm-console" -p 3780:3780 -e ACTIVATION_KEY='AAAA-BBBB-CCCC-DDDD' rapid7/rapid7-vm-console
```

Activate by License File with ACTIVATION_LICENSE_FILE environment variable:
```
docker run --init -d --name "vm-console" -p 3780:3780 -e ACTIVATION_LICENSE_FILE='LICENSEFILECONTENTS' rapid7/rapid7-vm-console
```

### Setting environment variables
It is possible to set a variety of environment variables at runtime to influence the functionality of the docker 
containers.  Below are a list of environment variables possible:

| Environment Variable    | Description                                       | Default    | Applicable Image  |
|-------------------------|---------------------------------------------------|------------|-------------------|
| API_USER                | User for interacting with console API             | nxadmin    | rapid7-vm-console |
| API_PASSWORD            | Password of API user                              | nxpassword | rapid7-vm-console |
| CONSOLE_PORT            | Console web/API port                              | 3780       | rapid7-vm-console |
| ACTIVATION_KEY          | Activation key leveraged to license console       |            | rapid7-vm-console |
| ACTIVATION_LICENSE_FILE | Contents of license file used to license console  |            | rapid7-vm-console |
| SEED_CONSOLE            | Pre-populate console with data (work in progress) |            | rapid7-vm-console |
| SECRET                  | Shared secret used for pairing engine to console  |            | rapid7-vm-engine  |
| CONSOLE                 | Console host or IP address used when pairing      |            | rapid7-vm-engine  |

### Upgrading
Due to the nature of InsightVM/Nexpose, upgrades are not supported by use of new images and updates will be auto applied
with the standard automated process.  Future investigation into handling upgrades with the Docker images may occur as an
enhancement.

### Building

Build Installer:
```
docker build -t rapid7/rapid7-vm-installer installer/
```

Build Console:
```
docker build -t rapid7/rapid7-vm-console console/
```

Build Engine:
```
docker build -t rapid7/rapid7-vm-engine engine/
```
