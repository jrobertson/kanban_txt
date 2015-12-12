#!/usr/bin/env ruby

# file: kanban_txt.rb

require 'recordx'
require 'fileutils'


class KanbanTxt
  
  attr_reader :to_s

  def initialize(filename='kanban.txt', title: nil, 
               headings: ['Backlog', 'Todo', 'In progress', 'Done'], path: '.')
    
    if title.nil? then
      raise 'KanbanTxt: title: must be provided e.g. ' + \
                                        'KanbanTxt.new title: "project1"'
    end
    
    @filename, @path, @title, @headings = filename, path, title, headings
    @keys = @headings.map{|x| x.downcase.gsub(/[\s\-_]/,'').to_sym}
    
    fpath = File.join(path, filename)
    
    if File.exists?(fpath) then
      
      @rx = import_to_rx(File.read(fpath))

    else      
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
    
    # archive the daily planner
    # e.g. kanban/gtk2html/2015/k121215.xml
        
    archive_path = File.join(@path, @title, @d.year.to_s)
    FileUtils.mkdir_p archive_path    
    filename = @d.strftime("k%d%m%Y.xml")
    
    File.write File.join(archive_path, filename), rx.to_xml
    
  end
    
  def import_to_rx(s)

    raw_rows = s.split(/.*(?=^[\w, ]+\n\-+)/)
    
    raw_rows.shift
    rows = raw_rows.map do |x| 
      a = x.lines
      a.shift 2
      a.join.strip
    end

    new_rx(@keys.zip(rows))
    
  end

  def rx_to_s(rx)
    
    len = @headings.length
    values = @rx.to_h.values[1..-1]
    a = @headings.zip(values)

    a2 = a.map do |title, value|
      row = []
      row << title + "\n" << '-' * title.length + ("\n\n" + value).rstrip + "\n"
      row.join
    end
    
    "%s\n%s\n\n%s\n" % [@rx.title, '=' * rx.title.length, a2.join("\n")]

  end
  
  def new_rx(h=@keys.zip([''] * @headings.length))
    
    title = @title + ' Kanban'
    RecordX.new({title: title }.merge(Hash[h]))
    
  end

end
