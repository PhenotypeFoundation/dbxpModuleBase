package org.dbxp.moduleBase

import org.springframework.web.context.request.RequestContextHolder
import org.codehaus.groovy.grails.commons.ConfigurationHolder

class AuthenticationService {
	def gscfService
	
    static transactional = false

    /**
     * Checks whether the user has been logged in
     * @param	requestMethod	HTTP request method for this request
     * @param	params			HTTP request parameters
     * @return	Map with status of authentication: [ "status": true/false, "redirect": null or url ]
     */
	public Map checkLogin( requestMethod, params ) {
		def session = getHttpSession()
		
		// If a user is already logged in, only check whether the credentials are still valid. If not, the user should authenticate again
		if( session.user && session.user != null && session.sessionToken && gscfService.isUserLoggedIn( session.sessionToken ) ) {
			// If we don't refresh the user object, an old hibernate session could still be attached to the object
			// raising errors later on (Lazy loading errors)
			try {
				session.user.refresh()
				return [ "status": true ]
			} catch( Exception ex ) {
				// If an exception occurs, the user is not correctly refreshed. Send the user back to gscf
				session.user = null
				log.info( "User refresh failed" )
			}
		}
		
		// on all pages of the Metagenomics module a user should be present in the session
		if (session.sessionToken) {
			log.info("SessionToken found, ask GSCF for User information")

			// try to identify the user with the sessionToken, since the user has logged in before
			try {
				// First check if the user is authenticated. If he isn't, he should provide credentials at GSCF
				def authenticated = gscfService.isUserLoggedIn( session.sessionToken )
				
				if( !authenticated ) {
					log.info "Not authenticated at GSCF."
					if( requestMethod == "GET" ) {
						return [ "status": false, "redirect": gscfService.urlAuthRemote(params, session.sessionToken) ]
					} else {
						log.debug "POST request: redirect can't be handled properly"
						flash.message = "Unfortunately, your request could not be completed, because the system had to log you in first. Please try again."

						return [ "status": false, "redirect": gscfService.urlAuthRemote(null, session.sessionToken) ]
					}
				}
				
				// Now find the user data
				def user = gscfService.getUser( session.sessionToken )
				
				if( !user ) {
					throw new Exception( "User should be authenticated with GSCF, according to the isUserLoggedIn call, but is not when asked for details." )
				}

				// Locate user in database or create a new user (and save it in the http session)
				findOrUpdateUser( user )
				
				return [ "status": true ]
			} catch(Exception e) {
				log.error("Unable to fetch user from GSCF", e)
				throw new Exception( "GSCF instance at " + ConfigurationHolder.config.gscf.baseURL + " could not be reached. Please check configuration.", e )
			}
		} else {
			session.sessionToken = "${UUID.randomUUID()}"
			log.info("SessionToken created, redirecting to GSCF to let the user login! (SessionToken: ${session.sessionToken})")
			
			if( requestMethod == "GET" ) {
				return [ "status": false, "redirect": gscfService.urlAuthRemote(params, session.sessionToken) ]
			} else {
				log.debug "POST request: redirect can't be handled properly"
				flash.message = "Unfortunately, your request could not be completed, because the system had to log you in first. Please try again."
				return [ "status": false, "redirect": gscfService.urlAuthRemote(null, session.sessionToken) ]
			}
		}
		
		// Something is wrong if the code reaches this point.
		return [ "status": false ]
    }
	
	public User getLoggedInUser() {
		
	}
	
	public void logIn() {
		
	}
	
	/**
	 * Searches for the given GSCF user in the database, and updates it if necessary
	 * @param user	JSON object that resulted from the GSCF getUser call
	 * @return	void
	 */
	public void findOrUpdateUser( def user ) { 
		def session = getHttpSession()
		
		session.user = User.findByIdentifierAndUsername(user.id, user.username)
		if (!session.user){ // when not found, create a new user
			def gscfId = user.id;
			if( !gscfId ) {
				log.warn( "GSCF user registered without proper id: " + gscfId );
				gscfId = null
			}
			
			session.user = new User(identifier: gscfId, username: user.username, isAdministrator: user.isAdministrator).save(flush: true)
		} else if( session.user.isAdministrator != user.isAdministrator ) {	// If administrator status has changed, update the user
			session.user.isAdministrator = user.isAdministrator
			session.user.save()
		}

	}
	
	/**
	 * Returns a reference to the HTTP session
	 * @return
	 */
	protected def getHttpSession() {
		return RequestContextHolder.currentRequestAttributes().getSession()
	}
}
