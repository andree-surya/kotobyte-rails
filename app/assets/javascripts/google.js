
var Google = {}

Google.activateSignIn = function() {

	var clientID = $('meta[name=google-signin-client_id]').attr('content');

	gapi.load('auth2', function() {
		gapi.auth2.init({ client_id: clientID }).then(function() {

			Google.authInstance = gapi.auth2.getAuthInstance();
			Google.authInstance.isSignedIn.listen(Google.onSignedIn);
		});
	});
};

Google.signIn = function() {
	this.authInstance.signIn();
};

Google.isSignedIn = function() {
	return this.authInstance.isSignedIn.get();
};

Google.onSignedIn = function(success) {
	console.log('Success: ', success);
};
