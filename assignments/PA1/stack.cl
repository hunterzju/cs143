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
      nextNode <- nxt
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

   (* operate cmd stack *)
   set_stack_top(sTop: StackNode) : StackNode {
      topSTK <- sTop
   };
   get_stack_top() : StackNode {
      topSTK
   };

   (* push command 
    * push "+" and "s" use this function
    *)
   push_command(cmd_str : String) : StackNode {
      if (isvoid topSTK) then
         let nil : StackNode in {
            topSTK <- (new StackNode).init(cmd_str, nil);
         }   
      else
         let tmpNode : StackNode in {
            tmpNode <- topSTK.put_new_cmd(cmd_str);
            topSTK <- tmpNode.set_next(topSTK);
         }
      fi
   };

   (* pop command *)
   pop_command() : String {
      let ret_str : String in {
         ret_str <- topSTK.get_cmd();
         topSTK <- topSTK.get_next();
         ret_str;
      }
   };

   (* integer - push integer into stack *)
   push_integer(str : String, sTop : StackNode) : StackNode {
      (* TODO *)
      topSTK
   };

   (* 'e' - evaluate the top of stack *)

   (* 'd' - display contents of stack *)
   display_stack() : StackNode {
      (* TODO *)
      topSTK
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
      else out_string("other command not implented yet.\n")
      fi fi fi
   };

   main() : Object {
      let str_in : String, nil : StackNode in
      {
         stackTop <- (new StackNode).init("b", nil);
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
