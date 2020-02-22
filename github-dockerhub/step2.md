We will now make a change to the Controller.

Open the file `/root/spring-sample-app/src/main/java/com/example/springsampleapp/HelloController.java`{{open}}

**NOTE:  ** You may need to select the filename in the editor tree window to have the contents appear in the editor.

Change the `hello, world` message 

```
	@RequestMapping("/")
	public String hello() {
		return "hello, world.  " + toString();
	}
```

returned by Spring Controller to something other than `hello, world.`

The shell prompt shows that the master branch has been changed, showing `(master *)`

## Compile and run

Use the Spring Maven plugin to compile and run the application.

```
./mvnw spring-boot:run
```{{execute}}

Send a request to the app (will execute in a another terminal window)
```
curl localhost:8080
```{{execute T2}}

Press `# Ctrl+C`{{execute interrupt T1}} to stop the app before proceeding to the next step.

## Add, Commit and push to GitHub

Executing `git status`{{execute}} and `git diff`{{execute}} will show you the changes to the code.

Now let's `add`, `commit` the changes.

1. `git add .`{{execute}}
2. `git commit -m "changed hello world message"`{{execute}}


Next you should push your changes to the remote Git repository.  You will be asked to enter your GitHub username and password .

3. `git push`{{execute}}










