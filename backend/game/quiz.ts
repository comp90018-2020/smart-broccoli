import { ContextHandlerImpl } from "express-validator/src/chain";

class Quiz {

    constructor() { }
    
    isTokenValid(token: string): boolean{
        return true;
    }

    isCodeValid(code:string): boolean{
        return true;
    }

    handle(content: string): [boolean, string] {
        const contentJson = JSON.parse(content);
        let ret = false;
        let response:{[key: string]: any} = {'success':false};
        if (this.isTokenValid(contentJson.token)){
            if (this.isCodeValid(contentJson.code)){
                ret = true;
                response.msg = "You have joined in " + contentJson.quizId;
                response.success = true;
            }else{
                response.err ="Invalid code" 
            }

        }else{
            response.err ="Invalid token" 
        }
        return [false, JSON.stringify(response)];
    }
}

export { Quiz };