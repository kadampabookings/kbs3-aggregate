# Kadampa Business System 3 (KBS3)

A private extension of the open-source [Modality](https://github.com/modalityone/modality) project. A forked version of Modality (`kbs3-modality-fork`) is submoduled into this repository. 


## Inititalise
```sh
mkdir -vp kbs3-aggregate && cd kbs3-aggregate  
git clone --recursive https://github.com/nkt-kbs-project/kbs3-aggregate.git .  
```

## Checkout Submodules to their Main Branches
```sh
cd kbs2018 && git checkout main && cd ..  
cd kbs3 && git checkout main && cd ..  
cd kbs3-modality-fork && git checkout main && cd ..  
cd kbs3-webfx-extras-fork && git checkout main && cd ..  
cd kbs3-webfx-fork && git checkout main && cd ..  
cd kbs3-webfx-platform-fork && git checkout main && cd ..
cd kbs3-webfx-stack-fork && git checkout main && cd ..  
```

## Configure Git to Ignore Submodule Changes
```sh
git config submodule.kbs2018.ignore all  
git config submodule.kbs3.ignore all
git config submodule.kbs3-modality-fork.ignore all
git config submodule.kbs3-webfx-extras-fork.ignore all
git config submodule.kbs3-webfx-fork.ignore all
git config submodule.kbs3-webfx-platform-fork.ignore all
git config submodule.kbs3-webfx-stack-fork.ignore all  
```

## Create Feature Branch
```sh
git checkout staging
git checkout -b feature/feature-name-here
```

##
Conceptual, deployment and workflow details available on the [Team Project Dashboard](https://sites.google.com/kadampa.net/modality-team/home?authuser=0)
