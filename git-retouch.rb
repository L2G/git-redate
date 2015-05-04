#!/usr/bin/env ruby

def debug(msg)
  $stderr.puts msg
end

def files_to_redate
  files = []
  if ARGV.empty?
    output = %x(git ls-tree -r HEAD)
    output.split("\n").each do |tree_entry|
      (data, path) = tree_entry.split("\t")
      if /^100/.match(data)
        files << path
      end
    end
    files
  else
    ARGV.clone
  end
end

files_to_redate.each do |file|
  timestamp = Time.at(
    %x(git log --no-merges --pretty=%at -1 ORIG_HEAD..HEAD -- "#{file}").to_i
  )

  if timestamp.to_i > 0
    print "#{timestamp.strftime('%Y-%m-%d %H:%M:%S')} #{file}"
    if File.mtime(file) != timestamp
      File.utime(Time.now, timestamp, file)
      print " (changed)"
    end
    puts
  else
    puts "---- not found ---- #{file}"
  end
end
