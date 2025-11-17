import { Component, signal } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { CommonModule } from '@angular/common';
import { CommanderService } from './_services/commander.service';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, CommonModule],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {
  protected readonly title = signal('Randomize Commander');
  commanderInfo: any;
  isLoading = false;

  constructor(
    private commanderService: CommanderService
  ) {}

  ngOnInit() {
    this.loadCommander();
  }

  loadCommander() {
    this.isLoading = true;
    this.commanderService.getCommanders().subscribe({
      next: (data) => {
        console.log('Commanders data:', data);
        this.commanderInfo = data;
        this.isLoading = false;
      },
      error: (error) => {
        console.error('Error loading commander:', error);
        this.isLoading = false;
      }
    });
  }

  randomizeCommander() {
    this.commanderInfo = null;
    this.loadCommander();
  }
}

