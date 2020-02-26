# Spring Boot layered jar

We saw earlier that pack produced a layered OCI image, making subsequent image re-builds more efficient. Spring Boot 2.3.0.M1 does the same, and it takes a step further by embracing this idea and applying it to the contents _inside_ of the app jar file as well, making jar file re-builds more efficient.

In traditional Spring Boot fat jar files, your application classes are placed in a directory called `BOOT-INF/classes`, and dependencies are placed in a directory called `BOOT-INF/lib`. As of Spring Boot 2.3.0.M1, the contents are distributed more granularly into separate layers based on on how frequently they are likely to change.

To see the default layering introduced by Spring Boot 2.3.0.M1, run:
`java -Djarmode=layertools -jar spring-sample-app.jar list`{{execute}}

Read more about layered jars and creating Docker images with Spring Boot in this [blog post](https://spring.io/blog/2020/01/27/creating-docker-images-with-spring-boot-2-3-0-m1).



# ONLY FOR DOCKERFILE????

# ALSO NOT LAYERED BY DEFAULT. MUST OPT-IN:

<build>
	<plugins>
		<plugin>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-maven-plugin</artifactId>
			<configuration>
				<layout>LAYERED_JAR</layout>
			</configuration>
		</plugin>
	</plugins>
</build>