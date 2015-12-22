#!/usr/bin/env ruby

# file: kanban_txt.rb

require 'recordx'
require 'fileutils'


class KanbanTxt
  
  attr_reader :to_s
  attr_accessor :title

  def initialize(filename='kanban.txt', title: nil, 
               headings: ['Backlog', 'Todo', 'In progress', 'Done'], path: '.')
    
    @filename, @path, @title, @headings = filename, path, title, headings
    
    fpath = File.join(path, filename)
    
    if File.exists?(fpath) then
      
      @rx = import_to_rx(File.read(fpath))
      housekeeping(@rx)

    else      
      
      if title.nil? then
        raise 'KanbanTxt: title: must be provided e.g. ' + \
                                          'KanbanTxt.new title: "project1"'
      end      
      
      @keys = @headings.map{|x| x.downcase.gsub(/[\s\-_]/,'').to_sym}
      
      @rx = new_rx
    end
    
  end

  def rx()
    @rx
  end
  
  def save(filename=@filename)
        
    File.write File.join(@path, filename), rx_to_s(@rx)
        
  end
  
  def to_s()
    rx_to_s @rx
  end

  private
  
  def archive()
    
    # archive the kanban at most once a day
    # e.g. kanban/gtk2html/2015/k121215.xml
        
    archive_path = File.join(@path, @title, @d.year.to_s)
    FileUtils.mkdir_p archive_path    
    filename = @d.strftime("k%d%m%Y.xml")
    
    File.write File.join(archive_path, filename), rx.to_xml
    
  end
  
  
  # experimental feature
  # if a task group or task item is prefixed with a 'x ' then it 
  # will be moved to the next column
  #
  def housekeeping(rx)
    
    columns = rx.to_h.values
    
    for i in (0..columns.length - 1)

      a = columns[i].lines

      marked = a.select {|x| x[/^x\s+/m]}

      marked.each do |task|

        groupid = task[/\w+\d+(?:\.\d+)?(?:\.\d+)?/]
        group = a.grep /#{groupid}/
        first = a.index group.first
        a.slice!(first, group.length)

        if i + 1 < columns.length then
          columns[i+1] << "\n\n" unless columns[i+1].empty?
          columns[i+1] << task.sub(/^\s*x\s*/,'') + group[1..-1].join.strip
        end

      end

      columns[i] = a.join.gsub(/^\n\n/,"\n")

    end

    rx.to_h.keys.each.with_index do |column, i|
      @rx[column] = columns[i]
    end

  end
    
  def import_to_rx(s)
    
    rows = s.split(/.*(?=^[\w, ]+\n\-+)/)    
    @title = rows.shift[/^(.*)\s+Kanban$/,1]    
    
    @headings = rows.map {|x| x.lines.first.chomp}
    @keys = @headings.map{|x| x.downcase.gsub(/[\s\-_]/,'').to_sym}    
    new_rx(@keys.zip(rows[0..-1].map { |x| x.lines[2..-1].join.strip }))
    
  end

  def rx_to_s(rx)
    
    len = @headings.length
    values = @rx.to_h.values
    
    a = @headings.zip(values).map do |title, value|

      row = []
      row << title + "\n" << '-' * title.length + \
                            ("\n\n" + value.to_s).rstrip + "\n"
      row.join
    end

    h1 = @title + ' Kanban'
    "%s\n%s\n\n%s\n" % [h1, '=' * h1.length, a.join("\n")]

  end
  
  def new_rx(h=@keys.zip([''] * @keys.length))

    RecordX.new(Hash[h])
    
  end

end