---
layout: default
title: Managing Dependencies
parent: Usage
nav_order: 3
---

# Managing Dependencies

Factory definition files are Plain Ol' Ruby. If you depend on another factory because you either extend from it or use it just add a `require` or (depending on your load path) `require_relative` to the top of your file. 
