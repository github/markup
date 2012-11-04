# A Location Indicator for iPhone

#### A location indicator for use with MapKit on the iPhone.

 
 

Long before Apple's foray into maps, I had the project which allowed me to play around with the MapKit framework in iOS. I developed the following “location indicator” UI component to eliminate the need for having a “locate-user” button cluttering up your interface. It also allows the user to see where they are in relation to the portion of the map they are viewing, something you normally can’t do if the user’s location is off-screen. I’ve included a simple project showing how the location indicator works.

The idea is simple, when the user’s location is displayed on the map but scrolled off-screen, the location indicator fades in and points towards the user’s location. The code uses the *mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated* MKMapView delegate method to update the location indicator each time the map is moved and the user’s location remains off-screen.

### How does it work?

The meat and potatoes of the code is the *(void)animateUserArrow* method. It determines the location of the location indicator, as well as the rotation of the arrow which points towards the user’s location off-screen. This methods calculates where the location indicator should be placed by dividing the in half both horizontally and vertically. It then calculates the x and y differences between the center pixel of the map view and the pixel position of the user’s current location off-screen.

<img src="http://www.craftmobile.ca/wp-content/uploads/2012/01/location-indicator-design.002.png">

Once we determine which quarter of the screen we are dealing with, we calculate the angle of the line (the one running between the centre point and the user’s location off-screen) to find out which half of the screen quarter the line resides on. We need to know this information in order to figure out which value we need to position the location indicator. In the example below, we know that the indicator’s x-position is at the rightmost visible portion of the screen. What we don’t know is the y-position of the indicator, which we can determine using the angle of the line between the centre point and the user’s location.

<img src="http://www.craftmobile.ca/wp-content/uploads/2012/01/location-indicator-design.003.png">

Similarly, if the line is within the top quadrant we now know the y-position of the indicator. What we don’t know, however, is the x-position. Once again, we kind find this using the previously calculated angle of the triangle shown below.

<img src="http://www.craftmobile.ca/wp-content/uploads/2012/01/location-indicator-design.004.png">

Once the location indicator is placed, all that’s left to do is determine the arrow rotation. Since the arrow starts pointing north, we determine it’s rotation (in the case of the top-right of the screen at least) by subtracting the aforementioned angle from 90 degrees calculated in radians (the iPhone uses radians, not degrees).  

<img src="http://www.craftmobile.ca/wp-content/uploads/2012/01/location-indicator-design.005.png">

I know I said that the arrow rotation was the last thing to deal with, and I lied. If we built the component as described above, half of the location indicator would be off-screen. In order to remedy this, we create artificial bounds, which are incorporated into the calculations instead of using the view’s bounds. This way the location indicator is constrained to a smaller rectangle and won’t get cut off.  

<img src="http://www.craftmobile.ca/wp-content/uploads/2012/01/location-indicator-design.006.png">

Hopefully this short set of diagrams gives you enough of an idea of how this component works that you can take a look at the code and appreciate what’s being done in the background. Feel free to ask questions in the comments section below, and I’ll do my best to clarify things if need be.

### Get the code!

Please feel free to make use of this code, provided you abide by the included license. If you end up shipping an app that uses the location indicator, I'd love to see it! You can visit www.craftmobile.ca in order to get in touch with me.
