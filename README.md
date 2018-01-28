# Syrup
Custom language syntax transpiler/converter

Define your custom language syntax in a .config.[lang you're using].syp (i.e .config.java.syp or .config.py.syp) file and and write custom code that transpiles to a supported language of your choice!

## Instructions

### Build
1. Clone Project

2. ``` gem install bundler ```

3. ``` bundle install ```

### Configure syntax
Create .syp file containing JSON definitions in the following form

```javascript
{
  "directories": {
      "java": [
          "java/",
          "java/libs/",
          "java/utils/"
      ]
  },
```

Using the above config you can specify which directories to use as your source with the language being a choice as well.  

```javascript
  "rules": [
      {
          "rule": [
              "$$$Var$$$ continue ()$$$COND$$$)", use $$$ for variables
              "-->>",
              "do $$$Var$$$ while ($$$COND$$$)"
          ]
      },
```
  Rules are how you define your new syntax. variables capture strings of arbitrary length. You are adjusting the other syntax.
  You can also specify multiline rules.
  Here is another Java Example for printing.
```javascript

      {
        "rule": [
          "multiline": true,
          "rule": [
              "p $$$ARGS$$$;",
              "-->>",
              "System.out.println($$$ARGS$$$);"
          ]
      },
}
```

### Run

To run do the following.
* Add the full path to Syrup/exe to your path
* Use the following command in the terminal
* If you define files in the Config, it'll run on those else it'll run on the files in your current directory.
* syrup -l [$Language You're Using]  
