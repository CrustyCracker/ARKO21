#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>

#include "f.h"

#include "allegro5/allegro.h"
#include "allegro5/allegro_image.h"
#include "allegro5/allegro_primitives.h"

#pragma pack(1)


// Consts

#define BMP_FILE_NAME "curve.bmp"


#define BMP_HEADER_SIZE 54
#define BMP_PIXEL_OFFSET 54
#define BMP_PLANES 1
#define BMP_BPP 24
#define BMP_HORIZONTAL_RES 500
#define BMP_VERTICAL_RES 500
#define BMP_DIB_HEADER_SIZE 40

// Globals
int width = 800;
int* width_ptr = &width;
int height = 800;
int* height_ptr = &height;


typedef struct {
    unsigned char sig_0;
    unsigned char sig_1;
    uint32_t size;
    uint32_t reserved;
    uint32_t pixel_offset;
    uint32_t header_size;
    uint32_t width;
    uint32_t height;
    uint16_t planes;
    uint16_t bpp_type;
    uint32_t compression;
    uint32_t image_size;
    uint32_t horizontal_res;
    uint32_t vertical_res;
    uint32_t color_palette;
    uint32_t important_colors;
} BmpHeader;

void write_to_bmp(unsigned  char *buffer, size_t size)
{
    FILE *file;

    file = fopen(BMP_FILE_NAME, "wb");
    if (file == NULL)
    {
        printf("Could not open output file.");
        exit(-1);
    }
    fwrite(buffer, 1, size, file);
    fclose(file);
}

unsigned char *generate_empty_bitmap(unsigned int width, unsigned int height, size_t *output_size)
{
    unsigned int row_size = (width*3 + 3) & ~3;
    *output_size = row_size * height + BMP_HEADER_SIZE;
    unsigned char *bitmap = (unsigned char *) malloc(*output_size);

    BmpHeader header;

    header.sig_0 = 'B';
    header.sig_1 = 'M';
    header.size = *output_size;
    header.reserved = 0;
    header.pixel_offset = BMP_PIXEL_OFFSET;
    header.header_size = BMP_DIB_HEADER_SIZE;
    header.width = width;
    header.height = height;
    header.planes = BMP_PLANES;
    header.bpp_type = BMP_BPP;
    header.compression = 0;
    header.image_size = row_size * height;
    header.horizontal_res = BMP_HORIZONTAL_RES;
    header.vertical_res = BMP_VERTICAL_RES;
    header.color_palette = 0;
    header.important_colors = 0;

    memcpy(bitmap, &header, BMP_HEADER_SIZE);
    for (int i = BMP_HEADER_SIZE; i <*output_size; ++i)
    {
        bitmap[i] = 0x00;
    }

    return bitmap;
}


int main(int argc, char *argv[]){
    if(argc == 3){
        *width_ptr = atoi(argv[1]);
        *height_ptr = atoi(argv[2]);

    }
    size_t bmp_size = 0;
    unsigned char *buffer = generate_empty_bitmap(*width_ptr, *height_ptr, &bmp_size);
    write_to_bmp(buffer, bmp_size);

    int mouse_pos_x, mouse_pos_y;


    bool done = false;
    double coordinates[10];
    coordinates[0] = 0.0;
    int clicks = 0;


    //graphic library init
    al_init();
    al_init_image_addon();
    al_init_primitives_addon();
    al_install_mouse();

    ALLEGRO_DISPLAY  *display = NULL;
    ALLEGRO_BITMAP *bitmap = NULL;
    ALLEGRO_EVENT_QUEUE *event_queue = NULL;


    display = al_create_display(*width_ptr, *height_ptr); //creating a window,
    bitmap = al_load_bitmap(BMP_FILE_NAME);
    event_queue = al_create_event_queue();     //create event_queue
    al_register_event_source(event_queue, al_get_display_event_source(display));
    al_register_event_source(event_queue, al_get_mouse_event_source());


    while (!done)
    {
        ALLEGRO_EVENT ev;
        al_wait_for_event(event_queue, &ev);
        switch(ev.type){

        case ALLEGRO_EVENT_DISPLAY_CLOSE:
            done = true;

        case ALLEGRO_EVENT_MOUSE_BUTTON_DOWN:
            al_flip_display();

            mouse_pos_x = ev.mouse.x;
            mouse_pos_y = ev.mouse.y;

            coordinates[clicks] = (double)mouse_pos_x;
            coordinates[clicks+5] = (double)mouse_pos_y;


            printf("x:%d, y:%d\n", mouse_pos_x, mouse_pos_y);

            al_draw_filled_circle(mouse_pos_x, mouse_pos_y, 1, al_map_rgb(255, 255, 255)); //dots

            al_flip_display();
            clicks+= 1;
            if(clicks == 5){
                al_flip_display();
                f(coordinates, buffer);
                write_to_bmp(buffer, bmp_size);
                bitmap = al_load_bitmap(BMP_FILE_NAME);
                al_draw_bitmap(bitmap, 0, 0, 0);
                al_flip_display();
                clicks = 0;
            }

        default:
            break;
        }
    }
    al_destroy_display(display);
    return 0;
}

