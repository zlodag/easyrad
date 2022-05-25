;; ========================================
;; Emacs key simulation for PowerScribe 360
;; ========================================

#InstallKeybdHook
#UseHook

is_pre_x := 0
is_pre_spc := 0
SetKeyDelay 0


;; ============
;; Abstractions
;; ============

send_reset(key) 
{
  Send %key%
  global is_pre_spc := 0
  Return
}

if_mark_active(key)
{
  global
  if is_pre_spc
    Send +%key%
  Else
    Send %key%
  Return
}


;; ================
;; Editing commands
;; ================

delete_char() 
{ 
  send_reset("{Del}") 
}


delete_word()
{
  send_reset("^{Del}") 
}

delete_backward_char()
{
  send_reset("{BS}") 
}

kill_line()
{
  Send {ShiftDown}{END}{SHIFTUP}
  Sleep 25 ;[ms] this value depends on your environment
  Send ^x
  global is_pre_spc := 0
  Return
}

open_line()
{
  send_reset("{HOME}{Enter}{Up}") 
}

newline()
{
  send_reset("{Enter}") 
}

undo()
{
  send_reset("^z") 
}


;; =======
;; Motions
;; =======

move_beginning_of_line()
{
  if_mark_active("{HOME}")
}

move_end_of_line()
{
  if_mark_active("{END}")
}

move_beginning_of_file()
{
  if_mark_active("^{HOME}")
}

move_end_of_file()
{
  if_mark_active("^{END}")
}

previous_line()
{
  if_mark_active("{Up}")
}

next_line()
{
  if_mark_active("{Down}")
}

forward_char()
{
  if_mark_active("{Right}")
}

backward_char()
{
  if_mark_active("{Left}")
}

forward_word()
{
  if_mark_active("^{Right}")
}

backward_word()
{
  if_mark_active("^{Left}")
}

quit()
{
  send_reset("{ESC}")
}

;; ===========
;; Keybindings
;; ===========

^vk20::
{ 
    If is_pre_spc 
        is_pre_spc := 0
    Else
        is_pre_spc := 1
    Return
 }

^d::delete_char()

!d::Send ^{Del}

^h::delete_backward_char()

!h::Send ^{BS}

^k::kill_line()

^o::open_line()

^j::newline()

^a::move_beginning_of_line()

^e::move_end_of_line()

!a::move_beginning_of_file()

!e::move_end_of_file()

^p::previous_line()

^n::next_line()

^f::forward_char()

!f::forward_word()

^b::backward_char()

!b::backward_word()

^/::undo()

^g::quit()

^s::send_reset("^f")

^r::send_reset("^h")

^y::send_reset("^v")

^w::send_reset("^x")

!w::send_reset("^c")
