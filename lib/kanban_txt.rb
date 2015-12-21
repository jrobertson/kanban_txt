#!/usr/bin/env ruby

# file: kanban_txt.rb

require 'recordx'
require 'fileutils'


class KanbanTxt
  
  attr_reader :to_s

  def initialize(filename='kanban.txt', title: nil, 
               headings: ['Backlog', 'Todo', 'In progress', 'Done'], path: '.')
    
    @filename, @path, @title, @headings = filename, path, title, headings
    
    fpath = File.join(path, filename)
    
    if File.exists?(fpath) then
      
      @rx = import_to_rx(File.read(fpath))

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
    
  def import_to_rx(s)
    
    rows = s.split(/.*(?=^[\w, ]+\n\-+)/)    
    @title = rows.shift[/^(.*)\s+Kanban$/,1]    
    
    @headings = rows.map {|x| x.lines.first.chomp}
    @keys = @headings.map{|x| x.downcase.gsub(/[\s\-_]/,'').to_sym}    
    new_rx(@keys.zip(rows[0..-1].map { |x| x.lines[2..-1].join.strip }))
    
  end

  def rx_to_s(rx)
    
    len = @headings.length
    values = @rx.to_h.values[1..-1]

    a = @headings.zip(values).map do |title, value|
      row = []
      row << title + "\n" << '-' * title.length + \
                            ("\n\n" + value).rstrip + "\n"
      row.join
    end
    
    "%s\n%s\n\n%s\n" % [@rx.title, '=' * rx.title.length, a.join("\n")]

  end
  
  def new_rx(h=@keys.zip([''] * @keys.length))

    RecordX.new({title: @title + ' Kanban' }.merge(Hash[h]))
    
  end

end