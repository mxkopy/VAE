using JSON, HTTP

function frontend_html( request::HTTP.Request )

    frontend_html = open( "$(ENV["SRC_TARGET"])/frontend.html" ) |> Base.read

    return HTTP.Response( 200, ["Accept" => "text/html"], frontend_html )

end



function frontend_js( request::HTTP.Request )

    frontend_js = open( "$(ENV["SRC_TARGET"])/frontend.js" ) |> Base.read

    return HTTP.Response( 200, ["Accept" => "text/javascript"], frontend_js )

end


const router = HTTP.Router()
HTTP.register!( router, "/frontend.html", frontend_html )
HTTP.register!( router, "/frontend.js", frontend_js )
