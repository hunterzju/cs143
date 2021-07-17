(*
 *  CS164 Fall 94
 *
 *  Programming Assignment 1
 *    Implementation of a simple stack machine.
 *
 *  Skeleton file
 *)

(*
 * class to implement an stack:
 * init, push, pop, empty
 *)

class StackNode {
   command : String;
   nextNode : StackNode;

   (* init stack *)
   init(cmd : String, next : StackNode) : StackNode {
      {
         command <- cmd;
         nextNode <- next;
         self;
      }
   };

   (* push entry into stack
    * split into put_new_cmd and set_next
    *)
   put_new_cmd(cmd : String) : StackNode {
      let newNode : StackNode in 
      {
         newNode <- (new StackNode).init(cmd, self);
         newNode;
      }
   };
   set_next(nxt : StackNode) : StackNode {
      {
         nextNode <- nxt;
         self;
      }
   };

   (* pop entry from stack
    * split into get_cmd and get_next
    *)
   get_cmd() : String {
      command
   };
   get_next() : StackNode {
      nextNode
   };
};

(*
 * class to implement an stack machine
 *)
class StackCommand inherits A2I {
   topSTK : StackNode;
   tmpNode : StackNode;

   (* operate cmd stack *)
   set_stack_top(sTop: StackNode) : StackNode {
      topSTK <- sTop
   };
   get_stack_top() : StackNode {
      topSTK
   };

   (* push command 
    * push "+","s" and integer use this function
    *)
   push_command(cmd_str : String) : StackNode {
      if (isvoid topSTK) then
         let nil : StackNode in {
            topSTK <- (new StackNode).init(cmd_str, nil);
         }   
      else
         {
            tmpNode <- topSTK.put_new_cmd(cmd_str);
            topSTK <- tmpNode.set_next(topSTK);
         }
      fi
   };

   (* pop command *)
   pop_command() : String {
      let ret_str : String in {
         if(isvoid topSTK) then{
            ret_str;
         }
         else {
            ret_str <- topSTK.get_cmd();
            topSTK <- topSTK.get_next();
         }fi;
         ret_str;
      }
   };

   (* execute '+' *)
   execute_plus() : StackNode {
      let num1 : String,
          num2 : String,
          sum : String in {
             num1 <- pop_command();
             num2 <- pop_command();
             sum <- i2a(a2i(num1) + a2i(num2));
             topSTK <- push_command(sum);
          }
   };

   execute_s() : StackNode {
      let num1 : String,
          num2 : String in {
             num1 <- pop_command();
             num2 <- pop_command();
             topSTK <- push_command(num2);
             topSTK <- push_command(num1);
          }
   };

   (* 'e' - evaluate the top of stack *)
   evalute_stack_top() : StackNode {
      let top_str : String in {
         top_str <- pop_command();
         if (top_str = "+") 
         then topSTK <- execute_plus()
         else if (top_str = "s")
         then topSTK <- execute_s()
         else topSTK
         fi fi;
      }
   };

   (* 'd' - display contents of stack *)
   display_stack(sTop : StackNode) : Object {
      (* TODO *)
      let node : StackNode <- sTop,
         io : IO <- new IO in {
         while (not isvoid node) loop {
            io.out_string(node.get_cmd());
            io.out_string("\n");
            node <- node.get_next();
         }
         pool;
      }
   };

   (* 'x' - stop *)
   stop() : Object {
      let io : IO <- new IO in {
         io.out_string("Stop!\n");
         abort();
      }
   };
};


class Main inherits IO {
   stackCmd : StackCommand;
   stackTop : StackNode;

   new_line() : Object {
      out_string("\n")
   };

   prompt() : String {
      {
         out_string(">");
         in_string();
      }
   };

   parse_command(cmd_str : String) : Object {
      if (cmd_str = "s")
      then stackTop <- stackCmd.push_command(cmd_str)
      else if (cmd_str = "+")
      then stackTop <- stackCmd.push_command(cmd_str)
      else if (cmd_str = "x")
      then stackCmd.stop()
      else if (cmd_str = "e")
      then stackTop <- stackCmd.evalute_stack_top()
      else if (cmd_str = "d")
      then stackCmd.display_stack(stackTop)
      else stackTop <- stackCmd.push_command(cmd_str)
      fi fi fi fi fi
   };

   main() : Object {
      let str_in : String in
      {
         stackCmd <- new StackCommand;
         while true loop
            {
            str_in <- prompt();
            parse_command(str_in);
            }
         pool;
      }
   };

};
