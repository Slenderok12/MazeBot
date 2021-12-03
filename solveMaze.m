function solveMaze()
    
    myrobot = legoev3('usb');   
    mA = motor(myrobot, 'A');
    mB = motor(myrobot, 'B');

    mA.Speed = 100;
    mB.Speed = 100;

    sensor = sonicSensor(myrobot);  
    leftSensor = colorSensor(myrobot, 1);
    rightSensor = colorSensor(myrobot, 4);
    
    function moveForward()
        start(mA);
        start(mB);
    end
    function stopMotor()
        stop(mA, 1);
        stop(mB, 1); 
    end
    function callBack = turnRight(isSkipping)
        stop(mB, 1);
        callBack = "Right";
        pause(0.2);
        leftReflected = readLightIntensity(leftSensor, 'reflected');
        if(leftReflected < 5 && ~isSkipping) %if left is black
            mA = -50;
            pause(0.2);
            mA = 50;
            callBack = "Forward";
        end
        start(mB);
    end 
    function turnLeft()
        stop(mA, 1);
        pause(0.5);
        start(mA);
    end 
    function turnArround()
        mA.Speed = -50;
        pause(0.5);
        mA.Speed = 50;
    end

    
    turnsArray = [];  % 0 - left, 1 - forward, 2 - right, 3 - back
    crossIndexes = [];
    currentTurnIndex = 0;
    moveForward();

    pause(0.5);
    while 1
        leftReflected = readLightIntensity(leftSensor, 'reflected');
        rightReflected = readLightIntensity(rightSensor, 'reflected');
        distance = readDistance(sensor);
        isLeftBlack = leftReflected < 5;
        isRightBlack = rightReflected < 5;
        isBothYellow = abs(leftReflected-50) < 10 && abs(rightReflected-50) < 10; 
        
        if (isLeftBlack && isRightBlack)
            crossIndexes(end+1) = currentTurnIndex;
            turnsArray(end+1) = 0;
            turnLeft();
            continue;
        end
        if(isLeftBlack)
            turnsArray(end+1) = 0;
            currentTurnIndex = currentTurnIndex + 1;
            turnLeft();
            continue;
        end
        if(isRightBlack)
            currentTurnIndex = currentTurnIndex + 1;
            callBack = turnRight(false);
            if(callBack == "Forward")
                turnsArray(end+1) = 1;
            else
                turnsArray(end+1) = 2;
            end
            continue;
        end 
        
        if(isBothYellow)
            turnArround();
            turnArround();
            stopMotor();
            break;
        end

        if(distance < 5)
            turnArround();
            turnsArray = turnsArray([1:crossIndexes(end)]);
            crossIndexes = crossIndexes(1:end-1);
            continue;
        end

        pause(0.1);
    end
    turnIndex = 0;
    while 1
        leftReflected = readLightIntensity(leftSensor, 'reflected');
        rightReflected = readLightIntensity(rightSensor, 'reflected');
        if(rightReflected < 5 || leftReflected < 5)
            switch turnsArray(turnIndex)
                case 0
                    turnLeft();
                case 1
                    moveForward();
                case 2
                    turnRight(true);
                otherwise
                    moveForward();
            end
        end
        turnIndex = turnIndex + 1;
    
                    

        if(isBothYellow)
            turnArround();
            turnArround();
            stopMotor();
            break;
        end
    end

end
