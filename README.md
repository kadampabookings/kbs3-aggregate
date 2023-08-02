# Kadampa Business System 3 (KBS3)

A private extension of the open-source [Modality](https://github.com/modalityone/modality) project. A forked version of Modality (`kbs3-modality-fork`) is submoduled into this repository. 


## Init
```sh
mkdir -vp kbs3  
cd kbs3  
git clone --recursive https://github.com/nkt-kbs-project/kbs3.git .
git checkout staging
git checkout -b feature/feature-name-here
```

## Init Submodules for Development
```sh
cd kbs2018 && git checkout main && cd ..  
cd kbs3 && git checkout main && cd ..  
cd kbs3-modality-fork && git checkout main && cd ..  
cd kbs3-webfx-extras-fork && git checkout main && cd ..  
cd kbs3-webfx-fork && git checkout main && cd ..  
cd kbs3-webfx-platform-fork && git checkout main && cd ..
cd kbs3-webfx-stack-fork && git checkout main && cd ..  
```

##
Conceptual, deployment and workflow details available on the [Team Project Dashboard](https://sites.google.com/kadampa.net/modality-team/home?authuser=0)
