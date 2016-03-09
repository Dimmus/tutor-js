
# Overview

To help with writing Selenium tests, we have two types of helpers --
  * **utils**
    * UI agnostic
    * helps with things like
      * getting elements synchronously
      * resizing windows
      * taking screenshots...
  * **UI helpers**
    * attaches commonly useful util methods on common UI elements
    * extend the base `TestHelper` in `./test-element.coffee`

# Writing a new UI helper



# Writing a spec



# Guiding Principles

As much as possible, we want to:

  * Make specs easily readable for
    * UI processes involved
    * Expectations
  * Decouple locators from the rest of the tests, because
    * This reduces clutter from the logic of the UI actions
    * Writing more high-level tests spanning multiples pages and processes should not require knowledge of locators
    * Locators are likely the parts of tests that will need updating the most
  * Keep locators in one place per UI page/component
    * To help us find where we need to update locators, and avoid missing updating locators that are used repeatedly
  * Expose common UI methods on the UI helpers
    * Reduce repeated code for common actions such as login, course select, etc
    * Decouples different UI specific processes from each other

Following these patterns, a spec would likely involve:
  * The spec
    * Contains all `expect`s
    * Declarative control of UI
    * Has no locators (css, linkText, etc)
  * The UI helper
    * Exposes access to common elements
    * Exposes UI methods
    * Stores locators for update as needed
  * Additional UI helpers
    * For specs that involve multiple UI pages/components

# Modifying the base UI helper

Sometimes you will need to add methods for a UI item that would be helpful in multiple places.  Please add to the base `TestItemHelper` or `TestHelper` as appropriate.  Nothing that is particularly specific to one test or item should be added to the base helper.
