#!/usr/bin/env ruby

require "getoptlong" # Ruby stdlib

class GitRetouch
  def initialize
    @commit_timestamps = {}
  end

  def best_commit_for_file(file)
    commit = nil
    prev_commit = nil

    loop do
      if prev_commit.nil?
        commit = %x(git rev-list HEAD -1 -- "#{file}").chomp
      else
        commit = %x(git rev-list #{prev_commit}^ -1 -- "#{file}").chomp
      end

      if !ignored_commits.include?(commit) || commit.nil? || commit.empty?
        break
      end

      prev_commit = commit
    end

    return nil if commit.nil? || commit.empty?
    commit
  end

  def commit_timestamp(commit = nil)
    return nil if commit.nil?
    @commit_timestamps[commit] ||= Time.at(
      %x(git log --pretty=%at -1 #{commit}).to_i
    )
  end

  def files_to_retouch
    return @files_to_retouch if @files_to_retouch

    files = []
    if ARGV.empty?
      git_opts = 'ls-tree -r HEAD'
      output = %x(git #{git_opts})
      output.split("\n").each do |tree_entry|
        (data, path) = tree_entry.split("\t")
        if /^:?100/.match(data)
          files << path
        end
      end
      @files_to_retouch = files
    else
      @files_to_retouch = ARGV.clone
    end

    @files_to_retouch.freeze
  end

  def ignored_commits
    @ignored_commits ||= %x(git config --get-all retouch.ignoreCommit).split
  end

  def options
    return @options if @options

    @options = {}
    GetoptLong.new(
      ['--debug', '-d', GetoptLong::NO_ARGUMENT ],
      ['--quick', GetoptLong::NO_ARGUMENT ]
    ).each do |opt, _|
      case opt
      when '--debug'
        options[:debug] = true
      when '--quick'
        options[:quick] = true
      end
    end

    @options.freeze
  end

  def run!
    debug "Options: " + options.inspect
    debug "ARGV: " + ARGV.inspect
    unless ignored_commits.empty?
      debug "Ignored commits: " + ignored_commits.inspect
    end
    debug

    total = files_to_retouch.length
    n = 0

    files_to_retouch.each do |file|
      if total > 100
        n += 1
        researching_message = "Researching timestamps (#{n}/#{total})..."
        info_no_nl(researching_message + "\r")
      end

      timestamp = commit_timestamp(best_commit_for_file(file))

      unless timestamp.nil?
        if researching_message
          info_no_nl((" " * researching_message.length) + "\r")
        end
        info_no_nl "#{timestamp.strftime('%Y-%m-%d %H:%M:%S')} #{file}"
        if File.mtime(file) != timestamp
          File.utime(Time.now, timestamp, file)
          info " (changed)"
        else
          info
        end
      else
        info "---- not found ---- #{file}"
      end
    end

    info
  end

  private

  def debug(msg = '')
    $stderr.puts msg if options[:debug]
  end

  def info(msg = '')
    $stderr.puts msg
  end

  def info_no_nl(msg = '')
    $stderr.print msg
  end
end

GitRetouch.new.run!
