# Extra credit

If you want to see kpack automatically creating new builds when a code change occurs, you can:

1. Fork the [spring-sample-app repo](https://github.com/springone-tour-2020-cicd/spring-sample-app.git)
2. Update the GitHub URL in image.yaml to point to your fork
3. Use `kubectl apply` as above to update the Imagekubectl get builders,builds,clusterbuilders,images,sourceresolvers
4. Make a change to any file on the GitHub repo
5. Check kpack logs for `build 2` and/or check DockerHub to confirm a new image was built

Note: kpack requires the default persistent volume to be configured in the Kuberrnetes cluster in order to cache layers between builds. To see this in action, try this exercise on a cluster with a default PV. Make sure to uncomment the "cacheSize" setting in the image yaml configuration file to take advantage of caching between builds.