num = input("What element of the fibonacci sequence do you want? ")
try:
    num = int(num)

    if(num < 1):
        print("The number needs to be greater than equal to 1 :/")
    else:
        n1 = 1
        n2 = 0

        addTo1 = True
        for x in range(num): # Could do with list, I like this way though
            if addTo1:
                n1 = n1 + n2
            else:
                n2 = n1 + n2
            addTo1 = not addTo1

        print(n1 if not addTo1 else n2)

except ValueError:
    print("That wasn't an int :/")