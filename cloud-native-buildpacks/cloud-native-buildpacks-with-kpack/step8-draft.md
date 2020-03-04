# DRAFT DRAFT DRAFT -- clean up below
platform and operational controls

kpack is the open source, declarative build logic that build service uses to execute container builds
great way to preview TBS functionality
provide enterprise abstractions on top of kpack

kpack concepts:

Stack (CRD): consists of the pair of base OS image and image needed at runtime - those two taken together are a stack. eg bionic stack, based off of ubuntu right now

Store: like a repository for buildpacks, installed when you use kpack or build service. backs the deployment of the instance of build service, where you stick the buildpacks you wnat to use.

Configuration of buildpacks and stack is a Builder.
Builder produces an image via a Build
Image is output to Container Registry.


kpack:
    Build service can monitor source code - when new commit is made, buils service can rebuild the image

    Stack update - (eg to ubuntu base image) - update of stack would trigger build service as well

----------
So:
kpack: declarative set of modules that can trigger image rebiulds

tanzu buildpacks ecosystem - buy int build service means you're buying into a stream of updates of proprietary buildpacks built by ISVs that make your life much easier

pb CLI - simplifies kpack, rather than configure kpack using kubectl and custom resources, this can get challenging for developers to do across an enteprise. pb cli makes it simpler, exposing only what you need ot know

Installation - installation, upgrade and image relocation... smoother upgrade experience based on pivnet, etc...

Build webhook module - enterprises have their own CA certs, webhook allows enterprises to provisio their own cs certs in their builds. CA Certs/ HTTP Proxy - critical enterprise functionality

Projects (optional) - abstraction on top of namespaces, simplified multitenancy for customers not using TMC

Source Gateway (optional) - easy source upload without direct registry access - upload source code to build service without needing developer credentials on the workstation

Build Service is a curated set of all of the above components




BD tool designed to speed up process of dev writing code through to code running in prod.

combine source and builder to build image
builder  provided and curated by vmware
vmware provides new builders when cve's are available
no need to reconcile new base images with middle an app tiers

builders can be scoped to cluster or "projects"


kpack has namespace: image, builds, builders

OCI image layers:
base OS
middleware tier
app

(Each one has layers within it)

manifest.json file describes layers

all these blobs combine with a sha checksum - creates perception of a single thing by stackign and ordering these checksums

digest is the total of all the layers/checksums - we tag the digest, and they are similar and related, a tag is related to a digest, but theya re not the same. the tag is not immutable in the same way

but the image not actually a static or immutable thing, not a monolith though we have thuoght of it that way

With Dockerfile, every layer is rebuilt when you change one. But it doesn't have be this way.

Enter rebasing vs building:

replace base OS layer, for example, update manifest.json, stack other same layers on top of the new base, and produce an image with a new digest


Builder shipped as an OCI image - contains a stack and an array of buildpacks

Modularized buildpacks: example: jdk layer, maven layer, etc... each buildpack represents a layer.

Stacks: 2 OCI images: the  build image and the run image.

As builder gets updated with new versions of the stack, the builder is updated. Build Service can detect that and trigger a change to the images in our registry.

Build layer and Stack layers will have different things: e.g. JDK layer would go to build stack, and JRE or dynatrace for example would go to Run stack.

Builders sre supported, built, maintained by vmware.

Cluster scoped - vmware builders

Project scoped - for a particular team (single/multiple namespace(s)??? -- unclear how this differs between kpack and TBS...)



