#include <stdio.h>
#include <stdlib.h>

typedef struct s_lnode {
    int val;
    struct s_lNode *next;
} _listNode;

void print_str(const char *arr, int size)
{
    printf("[");
    for(int i=0; i<size ;i++){
        if(i != 0)
            printf(",");
        printf("%c",arr[i]);
    }
    printf("]\n");
}

void print_nums(const int *arr, int size)
{
    printf("[");
    for(int i=0; i<size ;i++){
        if(i != 0)
            printf(",");
        printf("%d",arr[i]);
    }
    printf("]\n");
}

void arrs_free(void **arrs, size_t arrssize)
{
    for(size_t i=0; i<arrssize ;i++)
    {
        if(arrs[i])
            free(arrs[i]);
    }
    free(arrs);
}

void print_llist(_listNode* list)
{
    printf("{");
    while(list)
    {
        printf("%d", list->val);
        list = list->next;
        if(list)
            printf(",");
    }
    printf("}\n");
}

void list_free(_listNode* list)
{
    _listNode* current = list;
    _listNode* nextNode;
    while(current)
    {
        nextNode = current->next;
        free(current);
        current = nextNode;
    }
}