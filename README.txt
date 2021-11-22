CS 4381/5381: TSE -- Cross-Platform Application Development, Fall 2021

		       HOMEWORK 3: FlutterBook
                 (File $Date: 2021/08/15 05:04:38 $)

Due: TBA

This assignment may be done individually or in pairs. If you do in
pair, however, you will need to fill out the contribution form.

In this assignment, you are to extend the FlutterBook app described in
Chapters 5-6 of the textbook. FlutterBook is a so-called personal
information manager app to store and manage four different types of
personal information, called "entities": appointments, contacts,
notes, and tasks. The app provides a way to enter items of each type,
store them on the device, and presents a way for them to be viewed,
edited, and deleted.

R1. Support a new type of entities of your choice. Pick an interesting
    entity type so that you can play with and Flutter features or
    widgets that are not explored by the existing entity types, e.g.,
    GridView (to show the list of items) and different ways of
    entering items (camera for scanning QR/bar code, voice recording,
    etc.).

R2. Introduce a new tab in the home screen to manipulate (add, view,
    edit, and delete) items of the new type.

R3. Store the items in a SQLite database.

R4. Separate your model or state classes from the view and control
    classes. Use the "scoped model" approach or another state
    management approach such as BLoC (see Chapter 5).

R5. Document your code using Dartdoc comments. 

1. (10 points) Design your extension and express your design by
   drawing a UML class diagram [1]. Include only those classes (and
   modules) that you introduced, not the existing ones.

   - Your class diagram should show the main components (classes) 
     of your app along with their roles and relationships. 
   - Your model (business logic) classes should be cleanly separated 
     from the view/control (UI or widget) classes.
   - For each class in your diagram, define key (public) operations
     to show its roles, or responsibilities.
   - For each association including aggregation and composition, include
     at least a label, multiplicities and directions.
   - For each class appearing in your class diagram, provide a brief 
     description.

2. (90 points) Code your design by making your code conform to your
   design.

3. (15 bonus points) Provide an option to store the items remotely in
    Google Firebase (https://firebase.google.com/docs/flutter/setup).
    In this way, the items can be shared in real-time by multiple
    instances of the app installed on different devices.

TESTING
	
   Your code should compile on Flutter version 1.12 or later
   versions. Your app should run correctly on Android and iOS.

WHAT AND HOW TO TURN IN
   
   You should submit your program along with supporting documents
   through Blackboard. You should submit a single zip file that
   contains:

   - UML class diagram along with a description (pdf or docx)
   - contribution form if done in pair (pdf or docx)
   - lib/... (Dart source code)
     Dart src directory in your project folder. Include only those Dart
     source code files that you introduced for your extension; do not
     include the base code of FlutterBook or non Dart files such as
     build files.
   - pubspec.yaml: lists package dependencies and other metadata.

   If you work in pair, include both names in the zip file name and
   make only one submission.

GRADING

   You will be graded on the quality of your design and how clear your
   code is. Excessively long code will be penalized: don't repeat code
   in multiple places. Your code should be well documented by using
   Dartdoc comments and sensibly indented so it is easy to read.

   Be sure your name is in the comments in your source code.

REFERENCES 

   [1] Martina Seidl, et al., UML@Classroom: An Introduction to
       Object-Oriented Modeling, Springer, 2015. Ebook.