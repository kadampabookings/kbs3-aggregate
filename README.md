# Kadampa Business System 3 (KBS3)

An extension of the [Modality](https://github.com/modalityone/modality) project. A forked version of Modality (`modality-fork`) is submoduled into this repository. 


## 1/ Initialise
```sh
mkdir -vp kbs3-aggregate && cd kbs3-aggregate  
git clone --recursive https://github.com/nkt-kbs-project/kbs3-aggregate.git .  
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
```

## 4/ Create KBS3-Aggregate Feature Branch
```sh
git checkout -b feature/feature-name-here
```

## 5/ Optional: Create Submodule Fork Feature Branch
```sh
cd <submodule fork>
git checkout -b feature/feature-name-here
```

##
Conceptual, deployment and workflow details available on the [Team Project Dashboard](https://sites.google.com/kadampa.net/modality-team/home?authuser=0)
