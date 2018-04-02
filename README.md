# FivesquareKit

## About

FivesquareKit is a general purpose framework for building software on macOS and iOS that supplements or extends the frameworks supplied by the system, hence the historically conventional suffix "Kit" in the name. The source is organized by the system framework that it extends or augments, and/or by the level in the system that it is intended to be used (e.g. "Core" is code that is generally usable everywhere).

The framework can be built for macOS or iOS and will include only the code that is applicable for that platform.

## History and status

FivesquareKit was created over the course of many years (parts of it probably came into existence as far back as 2005) and working on a wide variety of projects out of a desire to not invent the wheel for every project and/or to capture useful patterns in various domains. As such, it isn't really a single thing, it is written in Objective-C, and has no tests. Consider it a toolbox rather than a tool. You could use single parts of it, use the whole thing, or even take inspiration from it for something you do yourself. Have fun :)

As my personal philosophy on reusing code has shifted towards single-purpose frameworks that do not depend on each other (and towards Swift as the primary language) I am not really adding a much to FivesquareKit anymore (though I continue to use it, particularly the Core Data stack, on several projects). I have, however, periodically updated it over the last few years to keep up with the platforms.


## Authors

John Clayton (with inspiration from tons of people)


# License

MIT License
