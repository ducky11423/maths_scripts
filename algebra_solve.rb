# Known support:
# + - * / ^ ()
# -a
# a(b)
# (a)(b)
# functions(yeet)
# 
# TODO:
# Error handling for out of range thingos such as asin(2)
# Complex ?
# Better functions? Multi arguement (log base b)
# Sums


def letter?(lookAhead)
    lookAhead =~ /[[:alpha:]]/
end
  
def numeric?(lookAhead)
    lookAhead =~ /[[:digit:]]/
end

def matchSymbol(hash, str)
    hash.each do |k|
        return 1 if k == str
        return 2 if k.start_with? str
    end
    return 0
end

operationPriority = {
    "+" => 0,
    "-" => 0,
    "*" => 1,
    "/" => 1,
    "^" => 2
}

$symbols = {}

$functions = {
    'sin' => lambda {|x| Math.sin(x)},
    'cos' => lambda {|x| Math.cos(x)},
    'tan' => lambda {|x| Math.tan(x)},
    'sqrt' => lambda {|x| Math.sqrt(x)},
    'abs' => lambda {|x| Math.abs(x)},
    'asin' => lambda {|x| Math.asin(x)},
    'acos' => lambda {|x| Math.acos(x)},
    'atan' => lambda {|x| Math.atan(x)},
    'ln' => lambda {|x| Math.log(x)},
    'log' => lambda {|x| Math.log10(x)},
    'lg' => lambda {|x| Math.log2(x)},
}

constants = {
    "pi" => Math::PI,
    "e" => Math::E
}

$symbols = constants.keys + $functions.keys

class Piece
    def initialize(a, b, o)
        @pieceA = a
        @pieceB = b
        @operation = o
    end

    def evaluate
        @pieceA = @pieceA.evaluate if @pieceA.is_a?(Piece)
        @pieceB = @pieceB.evaluate if @pieceB.is_a?(Piece)

        return $functions[@operation].call(@pieceA) if $functions.has_key?(@operation)
        return @pieceA + @pieceB if @operation == "+"
        return @pieceA - @pieceB if @operation == "-"
        return @pieceA * @pieceB if @operation == "*"
        return @pieceA / @pieceB if @operation == "/"
        return @pieceA ** @pieceB if @operation == "^"
    end

    def to_s
        if @pieceB == 0 and $operation == "+" then
            return @pieceA
        end

        return @operation + "(" + @pieceA.to_s + ")" if $functions.has_key?(@operation)
        return @pieceA.to_s + @operation + @pieceB.to_s
    end
end

loop do
    print "Please input an expression: " 
    input = gets.chomp #Get input and remove LF
    input.gsub! ' ', '' #Remove all spaces

    inputChars = input.split '' #Split characters

    #Go through the characters, if a number is followed by a line, insert an * in (so that 3sin(x) turns into 3*sin(x))
    i = 0
    while i < inputChars.size
        if numeric?(inputChars[i]) and letter?(inputChars[i+1]) then
            inputChars.insert(i+1, '*')
        end
        i += 1
    end
    
    operations = Array.new
    substr = "" #String used to store current character pattern
    numstr = "" #String used to store current numbers

    #Iterate through all the characters
    inputChars.each do |c|
        if numeric?(c) or c == "." then
            numstr += c #If the character is part of a number, add it to to the number string
            substr = ""
        elsif numstr != "" then 
            operations.push numstr.to_f #If the character is not part of a number, but we were building a number string, convert the string to a number and add it to array
            numstr = "" #And clear of course
        end

        unless numeric?(c) or c == "." then
            substr += c #If not part of a number, add character to search string
            n = matchSymbol($symbols, substr) #Check search string in the symbol table

            if n == 0 then #No match
                substr = ""
                operations.push c
            elsif n == 1 then #Complete match
                operations.push substr
                substr = ""
            else #Partial match
                #nothing i think
            end
        end
    end

    operations.push numstr.to_f unless numstr == "" #If we were building a number, convert and add it


    #Misc things to do on the array
    i = 0
    while i < operations.size

        constants.each do |k, v|
            operations[i] = v if operations[i] == k #Convert any constants their actual values
        end

        operations[i] = Piece.new(operations[i], 0, "+") if operations[i].is_a?(Numeric) #Convert numbers to pieces

        #I don't think this bit is really neccesary, but it ensure that implied *'s are explicitly shown (except -a)
        if numeric?(operations[i]) and letter?(operations[i+1]) then
            operations.insert(i+1, '*')
        elsif letter?(operations[i]) and (numeric?(operations[i+1]) or letter?(operations[i+1])) then
            operations.insert(i+1, '*')
        end

        i += 1
    end

    #If the only thing is a number, convert it to a piece for the sake of it
    operations[0] = Piece.new(operations[0], 0, "+") if operations.size == 1
    
    #This is where the fun begins // converts 
    loop do
        break if operations.size == 1 #If there is only one thing (number), don't do it pls

        #Check if there are any functions or - immediately before a piece or Piece then Piece, implying *
        i = 0
        shouldnext = false
        
        while i < operations.size
            
            if $functions.has_key?(operations[i]) and operations[i + 1].is_a?(Piece) then
                #Convert func -> piece into piece
                operations[i] = Piece.new(operations[i+1], 0, operations[i])
                operations.delete_at(i + 1)

            elsif operations[i] == "-" and (i == 0 or !operations[i-1].is_a?(Piece)) and operations[i+1].is_a?(Piece) and operations[i+2] != "^"
                #Convert - -> piece into piece (* -1) IF there is not a piece before the -
                operations[i] = Piece.new(operations[i+1], -1, "*")
                operations.delete_at(i + 1)
            elsif operations[i].is_a?(Piece) and operations[i+1].is_a?(Piece)
                #Convert piece -> piece into piece * piece
                operations[i] = Piece.new(operations[i], operations[i+1], "*")
                operations.delete_at(i + 1)
            end
            i += 1
        end

        # Identify highest set of brackets
        # Identify highest priority
        # Split into two pieces joined with an operation

        maxdepth = 0
        maxdepthpos = 0
        maxdepthendpos = operations.size - 1
        atmaxdepth = true
        i = 0
        depth = 1

        while i < operations.size 
            
            if operations[i] == "(" then
                depth += 1
                if depth > maxdepth then
                    atmaxdepth = true
                    maxdepth = depth
                    maxdepthpos = i
                end
            end

            if operations[i] == ")" then
                maxdepthendpos = i if atmaxdepth
                atmaxdepth = false
                depth -= 1
            end

            i += 1
        end

        
        startpos = maxdepthpos #Set to start scanning from either the start, or the ( of the deepest set of brackets
        endpos = maxdepthendpos #Set to end the scan at the last #, or end of the list

        maxprio = -1
        maxpriopos = -1

        for i in startpos..endpos do
            prio = operationPriority[operations[i]]
            prio = -1 if prio == nil
            if prio > maxprio then
                maxprio = operationPriority[operations[i]]
                maxpriopos = i
            end
        end

        pieceA = nil
        pieceB = nil
        operation = nil

        if maxpriopos != -1 then
            if operations[maxpriopos - 1].is_a?(Numeric) or operations[maxpriopos - 1].is_a?(Piece) then
                pieceA = operations[maxpriopos - 1]
            end

            if operations[maxpriopos + 1].is_a?(Numeric) or operations[maxpriopos + 1].is_a?(Piece) then
                pieceB = operations[maxpriopos + 1]
            end

            operation = operations[maxpriopos]

            operations.delete_at(maxpriopos + 1)
            operations.delete_at(maxpriopos)
            operations.delete_at(maxpriopos - 1)

            operations.insert(maxpriopos - 1, Piece.new(pieceA, pieceB, operation))
        elsif operations[startpos] == "("
            operations.delete_at(startpos)
            operations.delete_at(startpos+1)
        end

        if operations[maxpriopos - 2] == "(" and operations[maxpriopos] == ")" then
            #operations.delete_at(n)
        end
    end
    
    
    output = operations[0]
    #output = operations[0].to_r if(operations[0].is_a?(Rational))
    output = operations[0].evaluate if(operations[0].is_a?(Piece))

    puts input + " = " + output.to_s
end

# 3(2+3 * 2)
# 3(2+\3 * 2\)
# 3\2+\3 * 2\\
# 3 * (2+(3 * 2)))

# ((2 + 3) / 2 * 5) - (2 * 3)
# ([2 + 3] / 2 * 5 ) - (2 * 3)
# ([[2 + 3] / 2] * 5) - (2 * 3)

# ((2 + 3) / 2 * 5) - (2 * 3)
# (a / 2 * 5) - (2 * 3)
# (b * 5) - (2 * 3)
# c - (2 * 3)
# c - d
# e

#maxdepth = 0
#maxdepthpos
#iterate through array
#   if char == (
#       depth += 1
#       if depth > maxdepth
#           maxdepth = depth
#           maxdepthpos = pos
#   if char == )
#       depth -= 1