# service-qiskit

This is an Open Horizon services configuration to deploy a docker container with QISKIT and Jupyter for Raspberry Pi.

QISKIT is both a quantum simulator and a tool that simplifies interfacing with IBM's quantum computing services in the IBM cloud. The Quantum Experience link below will guide you through the latter if you are interested in using the real thing!

There's a blog article to go along with this repo, here: 
[https://darlingevil.com/your-own-quantum-computer/](https://darlingevil.com/your-own-quantum-computer/)

This container was built to run on a Raspberry Pi 4B with 2GB RAM (with Raspberry Pi OS 10, buster). It should work on any Raspberry Pi model 2, 3, or 4, although you may need to expland swap space on the smaller machines as described below. It should also work on any 64-bit x86 host with Docker installed.

## Prerequisites

You need to install to use this container is docker. You can install docker on a Raspberry Pi with this one command:

```
curl -sSL https://get.docker.com | sh
```

When done, I recommend running this command so the pi user can use docker withut sudo:

```
sudo usermod -aG docker pi
```

After executing that command, exit your shell and open a new shell. In that new shell and all subsequent shells you will be able to run `docker` commands without `sudo`. E.g., try this:

```
docker ps
```

## To build this container

NOTE: You need a little more than 2GB of RAM to build the docker container (about 3.4GB I think).  Note also that this extra memory is not needed to **run** the container, only to **build** it. A 4GB or 8GB Pi therefore won't need this step so don't bother with it. However, since I am using a 2GB Raspberry Pi 4B, I increased the swap space with these commands:

```
sudo sed -i 's/CONF_SWAPSIZE=100/CONF_SWAPSIZE=1024/' /etc/dphys-swapfile
sudo /etc/init.d/dphys-swapfile stop
sudo /etc/init.d/dphys-swapfile start
```

Once you have that sorted out, these are the build steps:

1. Edit the Makefile to set your DockerHub ID in `DOCKERHUB_ID`

2. Edit the Makefile to set the `JUPYTER_TOKEN`. This is the token you will use to login to the Jupyter Notebook created by this container. So keep it secret. Keep it safe. :-)

3. Run `make build`. You should expect this to take a very long time. On my little Pi4B/2GB it took me more than 6.5 hours to run `make build`. Notably, the file, `lda_c_pk09.c.o` alone takes something like 30 minutes to build (and it also happens to be the first one, perhaps the only one, that causes memory to run out with just 2GB of RAM and the default 100MB of swap). It builds much faster on an Intel i7 CPU.

4. Optionally you can push your container image to DockerHub so you don't ever have to build it again:

```
make push
```

## To run the resulting container

Once it is built, it starts up very quickly from then onward.

```
make run
```

## To use the container

Point your favorite browser at `<raspberry-pi-address>:8888/`. Enter the `JUPYTER_TOKEN` value you set in the Makefile, and you will see the familiar Jupyter Notebooks interface. I installed just one example notebook, `quantum_not_gate_qiskit.ipynb`. You can select it and run through it to verify everything is working. To create your own notebook, pull down the "New" menu at the top right, and select "Python 3".

## To learn more

This YouTube video gives a brief QISKIT primer:
    [https://www.youtube.com/watch?v=V3hXSftZuoc](https://www.youtube.com/watch?v=V3hXSftZuoc)

The quantum NOT gate example from this set of guided exercises:
    [https://github.com/JavaFXpert/qiskit4devs-workshop-notebooks](https://github.com/JavaFXpert/qiskit4devs-workshop-notebooks)

The IBM Quantum Experience getting started guide:
    [https://quantum-computing.ibm.com/docs/](https://quantum-computing.ibm.com/docs/)

The official QISKIT documentation:
    [https://qiskit.org/documentation/](https://qiskit.org/documentation/)

## All Makefile targets

- `init` - mostly used for operator services to create the scaffolding of a new operator, or any form of code generation required to build
- `build` - build the container
- `dev` - open a shell in the container for development, with source dir mounted
- `run` - run container locally
- `stop` - stop and remove the container
- `agent-run` - deploy the container to your edge node using the agent
- `agent-stop` - stop the container running from `agent-run` 
- `test` - assumes container is running
- `push` - to docker compliant registry
- `publish-service` - verify and publish the service
- `publish-pattern` - publish the pattern using the properties defined in the `pattern.json` file
- `clean` - calls stop and also removes the container image
