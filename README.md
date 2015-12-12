# Introducing the kanban_txt gem

## Usage

    require 'kanban_txt'

    kt = KanbanTxt.new 'kanban.txt', title: 'Gtk2HTML'
    puts kt.to_s

Output:

<pre>
Gtk2HTML Kanban
===============

Backlog
-------

Todo
----

In progress
-----------

Done
----

</pre>

## Resources

* kanban_txt https://rubygems.org/gems/kanban_txt
* Kanban https://en.wikipedia.org/wiki/Kanban

kanban kanban_txt gem txt
