# Kadampa Business System 3 (KBS3)

An extension of the [Modality](https://github.com/modalityone/modality) project. A forked version of Modality (`modality-fork`) is submoduled into this repository. 


## 1/ Initialise
```sh
mkdir -vp kbs3-aggregate && cd kbs3-aggregate  
git clone --recursive https://github.com/kadampabookings/kbs3-aggregate.git .  
```


## 2/ Checkout Submodules to their Main Branches
```sh
cd kbsx && git checkout staging && cd ..  
cd kbs3 && git checkout staging && cd ..  
cd modality-fork && git checkout staging && cd ..  
cd webfx-extras-fork && git checkout staging && cd ..  
cd webfx-fork && git checkout staging && cd ..  
cd webfx-platform-fork && git checkout staging && cd ..
cd webfx-stack-fork && git checkout staging && cd ..  
cd webfx-parent-fork && git checkout staging && cd ..  
cd webfx-stack-parent-fork && git checkout staging && cd ..  
cd webfx-lib-javacupruntime-fork && git checkout staging && cd ..  
```


## 3/ Configure Git to Ignore Submodule Changes
```sh
git config submodule.kbsx.ignore all  
git config submodule.kbs3.ignore all
git config submodule.modality-fork.ignore all
git config submodule.webfx-extras-fork.ignore all
git config submodule.webfx-fork.ignore all
git config submodule.webfx-platform-fork.ignore all
git config submodule.webfx-stack-fork.ignore all  
git config submodule.webfx-parent-fork.ignore all  
git config submodule.webfx-stack-parent-fork.ignore all  
git config submodule.webfx-lib-javacupruntime-fork.ignore all  
```


## 4/ Optional: Create KBS3-Aggregate Feature Branch
```sh
git checkout -b feature/feature-name-here
```


## 5/ Optional: Create Submodule Fork Feature Branch
```sh
cd <submodule fork>
git checkout -b feature/feature-name-here
```


## 6/ Add Modality Configuration
```sh
cp ./modality-fork/.github/workflows/docker/ModalityDatabase.json conf/ModalityDatabase.json
```
Replace the default values in the conf/ModalityDatabase.json file with the connection details to your Postgres instance.


## 7/ Prepare IntelliJ IDEA
* Update your IntelliJ IDEA IDE to the latest version using the JetBrains Toolbox
* Start up IntelliJ IDEA
* Open the kbs3-aggregate/ folder


## 8/ Create the KBS3 Server Runtime Configuration
* Create a new 'Application' runtime configuration
* Name: KBS3 Server
* Runtime: Java 17
* Module: kbs-server-application-vertx
* Main class: dev.webfx.platform.boot.ApplicationBooter
* Run the configuration to test the server can connect to the database


## 9/ Create the KBS3 Back-Office Runtime Configuration
* Create a new 'Application' runtime configuration
* Name: KBS3 Back-Office
* Runtime: Java 17
* Module: kbs-backoffice-application-openjfx
* Main class: dev.webfx.platform.boot.ApplicationBooter
* Run the configuration to connect the Back-Office to the Server

If IntelliJ cannot find a module when running the configuration, try one or both of the following:

* Reload Maven
* Install application (Maven -> kbs3-aggregate -> Lifecycle -> Install)
