#!/bin/bash
cd "$(dirname "$0")/src" || exit 1
javac -cp "../lib/ojdbc17.jar" Main.java TakeExamPanel.java AdminPanel.java || exit 1
java -cp ".:../lib/ojdbc17.jar" Main
