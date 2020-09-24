import { ContextHandlerImpl } from "express-validator/src/chain";

class Quiz {

    constructor() { }
    
    isTokenValid(token: string): boolean{
        return true;
    }

    isCodeValid(code:string): boolean{
        return true;
    }

    /**
     * 
     * @param content Json string from client
     */
    handle(content: any): [boolean, string] {
        let ret = false;
        let response:{[key: string]: any} = {'success':false};
        if (this.isTokenValid(content.token)){
            if (this.isCodeValid(content.code)){
                ret = true;
                response.msg = "You have joined in " + content.quizId;
                response.success = true;
            }else{
                response.err ="Invalid code" 
            }

        }else{
            response.err ="Invalid token" 
        }
        return [ret, JSON.stringify(response)];
    }
}

export { Quiz };