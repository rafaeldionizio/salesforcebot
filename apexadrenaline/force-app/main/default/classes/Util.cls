public class Util {
    public static HttpResponse executeHttpRequest(String endPoint, String method, Map<String, String> headers, String body, Integer timeout){
        HttpRequest request = new HttpRequest();
        Http h = new Http();

        request.setEndpoint(endPoint);
        request.setMethod(method);
        request.setTimeout(timeout);

        if(method == 'POST' || method == 'PUT')
            request.setBody(body != null ? body : '');
        else if(body != null)
            request.setBody(body);

        for(String nomeHeader : headers.keySet()){
            request.setHeader(nomeHeader, headers.get(nomeHeader));
        }

        return h.send(request);
    }
}