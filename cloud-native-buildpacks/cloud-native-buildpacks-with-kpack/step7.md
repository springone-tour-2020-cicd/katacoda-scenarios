# Is it working?

kpack will automatically detect the latest git commit in the source code repo defined in image.yaml. It will create an image for our app using the builder declared in build.yaml, and finally it will publish the image to Docker Hub using the service account we created.

Check your Docker Hub organization to make sure a new image has been published.

You can check kpack logs using the kpack `logs` CLI:
```
logs -image spring-sample-app -build 1
```{{execute}}

You should recognize the same buildpack lifecycle we observed with pack and Spring Boot in the kpack logs. 

Read more about viewing kpack logs in this [blog post](https://starkandwayne.com/blog/kpack-viewing-build-logs).

You can also watch the kpack-controller logs:
```
kubectl logs -n kpack \
   $(kubectl get pod -n kpack | grep Running | head -n1 | awk '{print $1}') \
   -f
```{{execute}}

--------------------------------------------------
Extra credit: If you want to see kpack automatically creating new builds when a code change occurs, you can:
1. Fork the [spring-sample-app repo](https://github.com/springone-tour-2020-cicd/spring-sample-app.git)
2. Update the GitHub URL in image.yaml to point to your fork
3. Use `kubectl apply` as above to update the Imagekubectl get builders,builds,clusterbuilders,images,sourceresolvers
4. Make a change to any file on the GitHub repo
5. Check kpack logs for `build 2` and/or check DockerHub to confirm a new image was built
--------------------------------------------------