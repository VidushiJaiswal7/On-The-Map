# Summary
This application was created specifically for Udacity's iOS Developer Nanodegree. An app shows a map that shows information posted by other students. The map will contain pins that show the location where other students have reported studying. By tapping on the pin users can see a URL for something the student finds interesting. The user will be able to add their own data by posting a string that can be geocoded to a location, and a URL.

# Technologies Used
Stack View
Auto Layout
UIKit
Swift
Text Field Delegate
MapKit
CoreLocation
JSON data.
API's
Navigation/Tab Bar Controllers
Grand Central Dispatch

# User Interface
MeMe has three main view controllers :

LoginViewController: This view accepts email and password strings from users, with a “Login” button. The app also informs the user if the login fails. It differentiates between a failure to connect, and incorrect credentials (i.e., wrong email or password).

MapViewController: Allows users to see the locations of other students in two formats. - on the map or in a table view controller. When the user taps a pin, it displays the pin annotation popup, with the student’s name (pulled from their Udacity profile) and the link associated with the student’s pin.
Tapping anywhere within the annotation will launch Safari and direct it to the link associated with the pin.

PostingInformationViewController: When the Information Posting View is modally presented, the user sees a text fields: one that asks for a location.
When the user clicks on the “Find Location” button, the app will forward geocode the string. If the forward geocode fails, the app will display an alert view notifying the user. The the view then  changes and the location is presented in a small map view and a text field is presented for the user to add the link. Tapping the “Finish” button will post the location and link to the server.

# Conclusion
In conclusion, I have learned a lot by working on this project. I learned accessing networked data using Apple’s URL loading framework, authenticating a user using over a network connection, creating user interfaces that are responsive, and communicate network activity, use Core Location and the MapKit framework for to display annotated pins on a map.


