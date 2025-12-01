" plugin/ggml.vim

if exists('g:loaded_ggml_plugin')
  finish
endif

let g:loaded_ggml_plugin = 1

if !exists('g:ggml_last_tensor')
  let g:ggml_last_tensor = ''
endif

function! GGMLDebugInsert(tensor, count) abort
  let t = a:tensor
  let n = a:count

  let lines = [
  \ '    {',
  \ '        struct ggml_tensor* tensor = ggml_graph_get_tensor(gf, "' . t . '");',
  \ '        if (tensor != nullptr) {',
  \ '            float buffer[' . n . '];',
  \ '            ggml_backend_t backend = ggml_backend_sched_get_tensor_backend(sched.get(), tensor);',
  \ '            printf("Backend type: %s\n", ggml_backend_name(backend));',
  \ '            printf("Tensor type: %s\n", ggml_type_name(tensor->type));',
  \ '            ggml_backend_tensor_get_async(backend, tensor, buffer, 0, sizeof(buffer));',
  \ '            ggml_backend_sched_synchronize(sched.get());',
  \ '            for (int i = 0; i < ' . n . '; i++) {',
  \ '                printf("%s[%.2d] = %f\n", tensor->name, i, buffer[i]);',
  \ '            }',
  \ '        }',
  \ '    }',
  \ ]

  call append(line('.'), lines)

  let g:ggml_last_tensor = t

  redraw
  echohl WarningMsg
  echom 'GGML: Remember to check if ggml_set_output(' . t . ') might be needed.'
  echohl None

endfunction

function! GGMLStatusline() abort
  if exists('g:ggml_last_tensor') && g:ggml_last_tensor !=# ''
    return '[ggml: check ggml_set_output("' . g:ggml_last_tensor . '")]'
  endif
  return ''
endfunction

" Command and mapping use the simple-name function
command! -nargs=+ GGMLDebug call GGMLDebugInsert(<f-args>)

nnoremap <silent> <leader>gd :call GGMLDebugInsert(input('Tensor name: '), input('Count: '))<CR>
