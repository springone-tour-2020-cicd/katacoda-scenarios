Let's begin by creating a GitHub account if you don't already have one or prefer to create a new account for this tutorial.

*Skip this part if you already have an account that you want to use for this tutorial.*
<br>

Follow the inCreate a local clone of your fork   structions on GitHub's [Join GitHub](https://github.com/join) page to create an account.

Now let's create a new repository in your account by forking an existing project.

Navigate to the [spring-sample-app](https://github.com/springone-tour-2020-cicd/spring-sample-app) page in your browser and press the `FORK` button in the upper right hand corner of the screen.  Then select the account you want it to be forked into.


Now create a local clone of the fork by selecting the `Clone with HTTPS` button on the `Clone or Download` menu in the forked repo.  This will copy the web URL that you will paste into the following `git` CLI command

Type git clone, and then paste the URL you copied earlier. It will look like this, with your GitHub username instead of YOUR-USERNAME:

```
$ git clone https://github.com/YOUR-USERNAME/spring-sample-app
```

Now you have a local copy that you can `cd` into.

We will now make a change to the file located under `./spring-sample-app/src/main/java/com/example/springsampleapp/HelloController`.  Navigate to that file in the editor and change the message returned by the `hello` method in the Spring Controller.





