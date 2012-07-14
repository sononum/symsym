require 'osx/cocoa'
require 'find'

# DsymFile - wrapper around a .dSYM bundle
#
#
class DsymFile
  attr_reader :identifier, :version, :shortversionstring
  
  # Initializes a DsymFile with a path to a dSYM Bundle
  #
  # Extracts CFBundleIdentifier, CFBundleVersion and CFBundleShortVersionString from the Info.plist file inside the bundle
  def initialize(filename)
    @info_plist = OSX::NSDictionary.dictionaryWithContentsOfFile(File.join(filename, 'Contents/Info.plist'))
    return unless @info_plist
    @identifier         = @info_plist['CFBundleIdentifier'].to_s
    @version            = @info_plist['CFBundleVersion'].to_s
    @shortversionstring = @info_plist['CFBundleShortVersionString'].to_s
    @filename = filename
  end # initialize
  
  # Matches Report?
  #
  # Checks if the Bundle Identifier, Bundle Version and Bundle Short Version String of a given Crashreport matches to this dSYM Bundle
  def matches_report?(report)
    false
    true if @identifier =~ /#{report.identifier}/ && @version == report.version && @shortversionstring == report.shortversion
  end
  
  # return the filename
  def to_s
    @filename
  end
end # class DsymFile

# Symbolized
#
# A symbol of the Crashreport that has been desymbolized with gdb
class Symbolized
  attr_reader :startaddress, :endaddress, :line, :symbol, :filename
  # Initialize with an output line from gdb. This will extract the addresses, linenumber and source-file
  def initialize(s)
    s.gsub(/Line (\d*) of "(.*)" starts at address (0x[0-9a-f]*) <(.*)> and ends at (0x[0-9a-f]*)/).to_a
    @line = $1
    @filename = $2
    @startaddress = $3.hex if $3
    @symbol = $4
    @endaddress = $5.hex if $3
  end
end

# A class representing a crashreport
#
# This must be initialized with the crashreport as plain text, a path where to look for .dSYM bundlles can be given.
# The report can be de-symbolized with symbolicate!
class Crashreport
  
  @addresses = nil
  @dsymfile = nil 
  @isSymbolicated = false;
  @cmdfilepath = nil;
  
  attr_reader :identifier, :version, :shortversion, :report
  
  # Extracts the address from a crashreport-line
  def self.address_from_report_line(s)
    a = s[/(0x[0-9a-f]+)/, 1]
    return a.hex if a
    nil
  end
  
  # Creates a new Crashreport object
  #
  # r is the crash report as string. dsymfile is a path where this object will look for a matching .dSYM bundle
  def initialize(r, dsymfile=nil)
    @report = r
    @dsymfile = dsymfile
    @identifier         = @report[/Identifier:\s*(.*)/, 1]
    @shortversion       = @report[/Version:\s*(.*) \((.*)\)/, 1]
    @version            = @report[/Version:\s*(.*) \((.*)\)/, 2]
    findDysmFile(dsymfile)
  end
  
  # Find dSYM Bundle
  #
  # Look for a matching dSYM bundle. Use the current directory when nil
  def findDysmFile(searchpath)
    Find.find(searchpath || '.') do |f|
      if f =~ /.dSYM/
        dsymfile = DsymFile.new(f)
        if dsymfile.matches_report? self
          @dsymfile = dsymfile
          return
        end
      end
    end
  end
  
  # returns an array of all adresses found in the crashreport  
  def addresses
    return @addresses if @addresses
    @addresses = []
    @report.lines.each do |l|
      a = Crashreport.address_from_report_line(l)
      @addresses << a if a
    end
    @addresses
  end
  
  # de-symbolizes the crashreport
  #
  # The get the report with .report aftwards
  def symbolicate!
    return if @isSymbolicated
    buildgdbcommandfile
    gdbout = rungdb
    @symbols = []
    gdbout.lines.each do |l|
      @symbols << Symbolized.new(l)
    end
    
    addresses.each do |a|
      @symbols.each do |s|
        if s.startaddress  && a >= s.startaddress && a <= s.endaddress
          report.gsub!(/(0x.*#{a.to_s(16)}) (.*)/, "#{$1} #{s.symbol} (#{s.filename}:#{s.line})")
        end # address matches
      end # @symbols.each
    end# addresses.each
    @isSymbolicated = true
  end # symbolicate!
  
  private
  # runs gdb with the command file created by buildgdbcommandfile
  def rungdb
    gdbcmd = "gdb --batch --quiet -x \"#{@cmdfilepath}\" \"#{@dsymfile}\""
    gdbout = `#{gdbcmd}`
    gdbout
  end
  
  # build a command-file for gdb
  def buildgdbcommandfile
    return if @cmdfilepath
    @cmdfilepath = '/tmp/symsymcmd.txt'
    cmdfile = File.new(@cmdfilepath, 'w+')
    self.addresses.each do |l|
      cmdfile << "info line *#{l}\n"
    end
    cmdfile.close
  end # buildgdbcommandfile
end # class Crashreport
