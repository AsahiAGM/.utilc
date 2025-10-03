#include <stdio.h>
#include <stdlib.h>
#include "listnode.h"

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

void print_llist(struct ListNode* list)
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

void list_free(struct ListNode* list)
{
    struct ListNode* current = list;
    struct ListNode* nextNode;
    while(current)
    {
        nextNode = current->next;
        free(current);
        current = nextNode;
    }
}