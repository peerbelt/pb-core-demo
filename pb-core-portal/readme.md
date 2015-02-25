PeerBelt Portal Web App
=========================


- [How to install & run](#how-to-install--run)

# How to install & run
 - You need to have [node.js](http://nodejs.org/) and npm installed in order to take advantage of this project

 - This project uses [Grunt](http://gruntjs.com/) so you need to install it globally  `npm install -g grunt-cli`

 - This project also uses [Bower](http://bower.io/) so you need to install it globally  `npm install -g bower`

 - You need to run `npm install`   first in order to install the node.js dependencies

 - You need to run `bower install ` in order to install the client-side dependencies

 - In order to run the app: 

		`grunt server`

 - In order to distribute the application:

     `grunt dist`

## Dist Server
To start a server from the dist folder, do the following:

```
grunt serve:dist
```

## This app is based on the [Yoeman AngularJS generator](https://github.com/yeoman/generator-angular) so check it out and use its [goodies](https://github.com/yeoman/generator-angular#generators) when diving into development

Note: `rev` & `cdnify` tasks have been left out and the app is using [UI Router](https://github.com/angular-ui/ui-router)
