# Debugging TutorJS tests:

1. In tutor-js/ directory:
``` npm install karma-chrome-launcher/ ```
2. Update tutor-js/test/karma.config.coffee to use Chrome browser:
```
# browsers: ['PhantomJS']
browsers: ['Chrome']
```
3. Run gulp tdd
4. Set breakpoints as needed in Chrome instance that pops up

Notes:
1. Some tests seem to fail in the chrome instance, not sure why.  Will look into this

2. One very annoying thing is that it opens up a chrome instance every time you run the tests.  Will look into this as well.

