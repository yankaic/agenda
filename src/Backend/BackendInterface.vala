/***

    Copyright (C) 2014-2020 Agenda Developers

    This file is part of Agenda.

    Agenda is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Agenda is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Agenda.  If not, see <http://www.gnu.org/licenses/>.

***/
using Gee;

namespace Agenda {
    public class Backend : SqliteBackend {
        private HashMap<int, Task> tasks = new HashMap<int, Task>();

        public override Task[] list (Task parent) {
            Task[] database_subtasks = base.list(parent);
            Task[] subtasks = {};

            foreach (Task task in database_subtasks) {                    
                subtasks += get_memory_task(task);
            }
            return subtasks;
		}

        private Task get_memory_task(Task task) {
            if (!tasks.has_key(task.id))
                tasks.set(task.id, task);
            
            return tasks.get(task.id);
        }

        public override Task find (int id) {
            if (tasks.has_key(id))
                return tasks.get(id);
            
            Task task = base.find(id);
            tasks.set(id, task);
            return task;
		}

        public override void fetch (Task task) {
            Task[] subtasks = list(task);

            if (task.subtasks.length == subtasks.length)
                return;
            
            task.subtasks = subtasks;
		}

        public override void create (Task task, Task parent) {
            base.create(task, parent);
            tasks.set(task.id, task);
            parent.add(task);
		}

        public override void drop (Task subtask, Task parent) {
            base.drop(subtask, parent);
            parent.drop(subtask);            
		}

        public override void mark (Task task) {
            base.mark(task);
		}

        public override void changeParent(Task task, Task old_parent, Task new_parent) {
            base.changeParent(task, old_parent, new_parent);
            old_parent.drop(task);
            new_parent.add(task);
		}

        public override void reorder (Task task, Task parent) {
            base.reorder(task, parent);

            int originalposition = 0;
            int taskposition = task.position - 1;
            Task[] subtasks = parent.subtasks;
            while (subtasks[originalposition] != task)
                originalposition++;
            
            int increment = taskposition > originalposition ? 1 : -1;
            for (int i = originalposition; i != taskposition; i + increment) {
                subtasks[i] = subtasks[i + increment];
            }
            subtasks[taskposition] = task;
		}

        public override void create_link (Task task, Task new_parent) {
            base.create_link(task, new_parent);
            new_parent.add(task);
		}

        public override Stack readStack () {
            Stack dbstack = base.readStack();
            Stack revert_stack = new Stack();
            Stack stack = new Stack();

            while(!dbstack.is_empty())
                revert_stack.push(get_memory_task(dbstack.pop()));
            
            while(!revert_stack.is_empty())
                stack.push(revert_stack.pop());
            
            return stack;
		}

        public override void writeStack (Stack stack) {
            base.writeStack(stack);
		}

        public override void modify_description(Task task) {
            base.modify_description(task);
		}

        public override Task[] search(string text) {
            return base.search(text);
		}

    }
}
