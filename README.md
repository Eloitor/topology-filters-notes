# topology-filters-notes
Our notes can be found at https://eloitor.github.io/topology-filters-notes/definitions
 
## Features
- Notes are stored in plain text markdown files.
- LaTeX support is provided.
- Lean codeblock support with links to interactive examples.

## How to build this project

1. clone this repository
```
git clone github.com/eloitor/topology-filters-notes
```
2. Install `pandoc`, `make` and `python3`
```
sudo apt-get install pandoc make python3
```
3. Install `panflute`
```
pip3 install panflute
```
4. Build the project
```
make
```

You can also serve the project locally, which compiles the markdown files every time you edit one of them. For this, you need to install `entr` and `browser-sync`:
```
sudo apt-get install entr
npm install -g browser-sync
```
And then run the following command:
```
make serve
```


## Using docker

Alternatively, if you want to be sure to use the latest version of `pandoc` you can install `Docker`
```shell
sudo apt-get install docker
```
and run the docker container described in the `Dockerfile`:
```
make docker
```