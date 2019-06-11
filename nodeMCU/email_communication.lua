
email = {}


function email.send(brightness)
    local key = "by8p5qlIYimy6XPxB1xU5J"
    local email_post_url = "https://maker.ifttt.com/trigger/trigger2/with/key/" .. key .. "?value1=" .. tostring(289)
    http.post(email_post_url, nil, function(code, data)
    if (code < 0) then
        print("HTTP request failed")
    else
        print(code, "Email Sent")
    end
    end)
end

return email
