-- LuaU Studio Template V1.3
-- Constants
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local questionText = workspace.Map.Functional.Screen.SurfaceGui.MainFrame.MainGameContainer.MainTxtContainer.QuestionText

-- RemoteEvent
local GameEvent = ReplicatedStorage.Events.GameEvent

-- Cache methods
local gsub = string.gsub

-- Keep track of the last answered question
local lastAnsweredQuestion = ""

-- Function to fire the updateAnswer remote for each digit in sequence
local function fireUpdateAnswerSequence(answer)
    local answerStr = tostring(answer)
    
    -- Fire for each progressive part of the answer
    for i = 1, #answerStr do
        local partialAnswer = string.sub(answerStr, 1, i)
        
        local args = {
            [1] = "updateAnswer",
            [2] = partialAnswer
        }
        GameEvent:FireServer(unpack(args))
        
        -- Wait between fires
        task.wait(0.1)
    end
end

-- Connect to the text change event
questionText:GetPropertyChangedSignal("Text"):Connect(function()
    -- Get the current question text
    local expression = questionText.Text
    
    -- Skip processing if the text already contains an answer or is the same as last answered
    if expression:find("=.+%d") or expression == lastAnsweredQuestion then
        return
    end
    
    -- Save original question for tracking
    local originalQuestion = expression
    
    -- Format the expression for evaluation
    local evalExpression = expression
    evalExpression = gsub(evalExpression, "=.*$", "")  -- Remove equals sign and anything after it
    evalExpression = gsub(evalExpression, "x", "*")    -- Convert 'x' to '*' for multiplication
    
    -- Safely evaluate the expression
    local success, result = pcall(function() 
        return loadstring("return " .. evalExpression)() 
    end)
    
    -- Brief delay to ensure UI responsiveness
    task.wait(0.05)
    
    -- Update the text with the result if calculation was successful
    if success and type(result) == "number" then
        -- Format the result (round to 2 decimal places if it's not an integer)
        local formattedResult = result
        if result ~= math.floor(result) then
            formattedResult = math.floor(result * 100 + 0.5) / 100
        end
        
        -- Display original expression
        local displayExpression = gsub(evalExpression, "%*", "x")
        local finalText = displayExpression .. "= " .. formattedResult
        questionText.Text = finalText
        
        -- Update the last answered question
        lastAnsweredQuestion = originalQuestion
        
        -- Fire update answer sequence (e.g. for 128: "1", then "12", then "128")
        fireUpdateAnswerSequence(formattedResult)
        
        -- fire the final submitAnswer remote
        local submitArgs = {
            [1] = "submitAnswer",
            [2] = tostring(formattedResult)  -- Convert to string
        }
        GameEvent:FireServer(unpack(submitArgs))
    end
end)
