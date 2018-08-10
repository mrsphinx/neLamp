local module={}

function module._blank()
    local html=""
    html = "<html>\r\n"
    html = html.."<head>\r\n"
    html = html.."<meta http-equiv=\"Pragma\" content=\"no-cache\">\r\n"
    html = html.."<meta http-equiv=\"Expires\" content=\"-1\">\r\n"
    html = html.."<meta http-equiv=\"Content-type\" content=\"text/html; charset=UTF-8\">\r\n"
    html = html.."</head>\r\n"
    
    html = html.."<title>LED Control</title>\r\n"
    html = html.."</html>\r\n"
    return html 
end

return module